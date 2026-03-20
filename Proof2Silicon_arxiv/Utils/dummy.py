# import torch
# import torch.nn as nn
# import torch.optim as optim
# import numpy as np
# import math
# import random
# import subprocess

# # Define the neural network with policy and value heads
# class PromptNet(nn.Module):
#     def __init__(self, input_dim, hidden_dim, action_dim):
#         super(PromptNet, self).__init__()
#         self.shared = nn.Sequential(
#             nn.Linear(input_dim, hidden_dim),
#             nn.ReLU(),
#             nn.Linear(hidden_dim, hidden_dim),
#             nn.ReLU()
#         )
        
#         # Policy head
#         self.policy_head = nn.Sequential(
#             nn.Linear(hidden_dim, action_dim),
#             nn.Softmax(dim=-1)
#         )
        
#         # Value head
#         self.value_head = nn.Sequential(
#             nn.Linear(hidden_dim, 1),
#             nn.Tanh()
#         )

#     def forward(self, x):
#         shared_output = self.shared(x)
#         policy = self.policy_head(shared_output)
#         value = self.value_head(shared_output)
#         return policy, value

# # Define a node in the MCTS tree
# class MCTSNode:
#     def __init__(self, state):
#         self.state = state  # The current state (e.g., code + error context)
#         self.children = {}  # Map actions to child nodes
#         self.visit_count = 0
#         self.total_value = 0
#         self.prior = 0  # Prior probability from the policy network

#     def value(self):
#         if self.visit_count == 0:
#             return 0
#         return self.total_value / self.visit_count

# # Monte Carlo Tree Search (MCTS)
# class MCTS:
#     def __init__(self, model, c_puct=1.0):
#         self.model = model
#         self.c_puct = c_puct
#         self.nodes = {}

#     def select(self, node):
#         """Select the child node with the highest UCB value."""
#         best_value = -float('inf')
#         best_action = None
#         for action, child in node.children.items():
#             ucb_value = (child.value() + 
#                          self.c_puct * child.prior * math.sqrt(node.visit_count) / (1 + child.visit_count))
#             if ucb_value > best_value:
#                 best_value = ucb_value
#                 best_action = action
#         return best_action, node.children[best_action]

#     def expand(self, node, state, legal_actions):
#         """Expand the tree by adding all legal actions as children."""
#         input_tensor = torch.tensor(state, dtype=torch.float32).unsqueeze(0)
#         with torch.no_grad():
#             policy, _ = self.model(input_tensor)
#         policy = policy.squeeze(0).numpy()

#         for action in legal_actions:
#             if action not in node.children:
#                 child = MCTSNode(state)
#                 child.prior = policy[action]
#                 node.children[action] = child

#     def simulate(self, state):
#         """Simulate a rollout and return the value from the value network."""
#         input_tensor = torch.tensor(state, dtype=torch.float32).unsqueeze(0)
#         with torch.no_grad():
#             _, value = self.model(input_tensor)
#         return value.item()

#     def backup(self, path, value):
#         """Backup the value to all nodes in the path."""
#         for node in path:
#             node.visit_count += 1
#             node.total_value += value

#     def run(self, root_state, legal_actions, num_simulations=50):
#         """Run MCTS from the root state."""
#         if root_state not in self.nodes:
#             self.nodes[root_state] = MCTSNode(root_state)
#         root = self.nodes[root_state]

#         for _ in range(num_simulations):
#             node = root
#             path = [node]

#             # Selection
#             while node.children:
#                 action, node = self.select(node)
#                 path.append(node)

#             # Expansion
#             self.expand(node, node.state, legal_actions)

#             # Simulation
#             value = self.simulate(node.state)

#             # Backup
#             self.backup(path, value)

#         # Return the best action based on visit counts
#         best_action = max(root.children.items(), key=lambda item: item[1].visit_count)[0]
#         return best_action

# # Reward function

# def execute_prompt_on_code(state, prompt):
#     """Simulate applying a prompt to the code."""
#     code, error_context = state
#     modified_code = apply_prompt_to_code(code, prompt)
#     return run_verifier(modified_code)

# def apply_prompt_to_code(code, prompt):
#     """Mock function to modify the code based on the prompt."""
#     # Replace this with real logic for applying the prompt.
#     return code.replace("<error>", prompt)

# def run_verifier(code):
#     """Mock function to run the verifier on the modified code."""
#     # Simulate running a code verifier or compiler.
#     # Example: Run a command-line verifier and capture the output.
#     try:
#         # Example: `verifier_command` could be "dafny /verify code.dfy"
#         result = subprocess.run(
#             ["verifier_command", code],
#             capture_output=True,
#             text=True,
#             timeout=5
#         )
#         if result.returncode == 0:
#             return "Success", None  # Verification successful
#         else:
#             return "Failure", result.stderr  # Return error details
#     except Exception as e:
#         return "Error", str(e)

# def reward_fn(state, action):
#     """
#     Reward function for evaluating prompt effectiveness.
    
#     Args:
#         state (tuple): Current state, including code and error context.
#         action (int): Selected action (prompt index).
    
#     Returns:
#         next_state (tuple): Updated state after applying the prompt.
#         reward (float): Reward based on effectiveness.
#         done (bool): Whether the task is complete.
#     """
#     # Map action to a prompt (you can store prompts in a list or dict)
#     prompts = ["Fix syntax error", "Add missing semicolon", "Correct indentation", "Change variable name", "Add missing type"]
#     prompt = prompts[action]

#     # Apply the prompt and check the verifier
#     verification_result, error_details = execute_prompt_on_code(state, prompt)

#     if verification_result == "Success":
#         reward = 1.0  # Positive reward for success
#         done = True
#     elif verification_result == "Failure":
#         reward = -0.5  # Penalty for failing to resolve
#         done = False
#     else:
#         reward = -1.0  # Heavy penalty for errors (e.g., invalid syntax)
#         done = True  # Stop further attempts if an error occurs

#     # Update state (e.g., append the new prompt to the history)
#     next_state = (state[0], error_details)
#     return next_state, reward, done

# # Training loop

# def train_model(model, optimizer, num_iterations, legal_actions_fn, reward_fn, state_generator):
#     """Train the model using self-play and reinforcement learning."""
#     mcts = MCTS(model)
#     for iteration in range(num_iterations):
#         # Generate initial state
#         state = state_generator()

#         # Self-play to generate training data
#         states, actions, rewards = [], [], []
#         for _ in range(50):  # Fixed number of steps in an episode
#             legal_actions = legal_actions_fn(state)
#             action = mcts.run(state, legal_actions)
#             states.append(state)
#             actions.append(action)

#             # Apply the action to transition to the next state
#             next_state, reward, done = reward_fn(state, action)
#             rewards.append(reward)

#             if done:
#                 break
#             state = next_state

#         # Compute returns for value training
#         returns = [sum(rewards[i:] * (0.99 ** np.arange(len(rewards) - i))) for i in range(len(rewards))]

#         # Update the neural network
#         optimizer.zero_grad()
#         for state, action, return_value in zip(states, actions, returns):
#             input_tensor = torch.tensor(state, dtype=torch.float32).unsqueeze(0)
#             policy, value = model(input_tensor)

#             # Compute loss
#             target_policy = torch.zeros_like(policy)
#             target_policy[0, action] = 1.0
#             policy_loss = -torch.sum(target_policy * torch.log(policy))
#             value_loss = (value - return_value) ** 2

#             loss = policy_loss + value_loss
#             loss.backward()
#         optimizer.step()

# # Example usage
# if __name__ == "__main__":
#     input_dim = 10  # Example input dimensions (e.g., code features + error context)
#     hidden_dim = 128
#     action_dim = 5  # Example action space (e.g., possible prompts)

#     model = PromptNet(input_dim, hidden_dim, action_dim)
#     optimizer = optim.Adam(model.parameters(), lr=0.001)

#     def dummy_legal_actions_fn(state):
#         return list(range(action_dim))

#     def dummy_state_generator():
#         return ("int x = <error>;", "Syntax Error")  # Example state with code and error context

#     train_model(model, optimizer, num_iterations=100, legal_actions_fn=dummy_legal_actions_fn, reward_fn=reward_fn, state_generator=dummy_state_generator)












































# import torch
# import torch.nn as nn
# import torch.optim as optim
# import numpy as np
# import math
# import random

# # Define the neural network with policy and value heads
# class PromptNet(nn.Module):
#     def __init__(self, input_dim, hidden_dim, action_dim):
#         super(PromptNet, self).__init__()
#         self.shared = nn.Sequential(
#             nn.Linear(input_dim, hidden_dim),
#             nn.ReLU(),
#             nn.Linear(hidden_dim, hidden_dim),
#             nn.ReLU()
#         )
        
#         # Policy head
#         self.policy_head = nn.Sequential(
#             nn.Linear(hidden_dim, action_dim),
#             nn.Softmax(dim=-1)
#         )
        
#         # Value head
#         self.value_head = nn.Sequential(
#             nn.Linear(hidden_dim, 1),
#             nn.Tanh()
#         )

#     def forward(self, x):
#         shared_output = self.shared(x)
#         policy = self.policy_head(shared_output)
#         value = self.value_head(shared_output)
#         return policy, value

# # Define a node in the MCTS tree
# class MCTSNode:
#     def __init__(self, state):
#         self.state = state  # The current state (e.g., code + error context)
#         self.children = {}  # Map actions to child nodes
#         self.visit_count = 0
#         self.total_value = 0
#         self.prior = 0  # Prior probability from the policy network

#     def value(self):
#         if self.visit_count == 0:
#             return 0
#         return self.total_value / self.visit_count

# # Monte Carlo Tree Search (MCTS)
# class MCTS:
#     def __init__(self, model, c_puct=1.0):
#         self.model = model
#         self.c_puct = c_puct
#         self.nodes = {}

#     def select(self, node):
#         """Select the child node with the highest UCB value."""
#         best_value = -float('inf')
#         best_action = None
#         for action, child in node.children.items():
#             ucb_value = (child.value() + 
#                          self.c_puct * child.prior * math.sqrt(node.visit_count) / (1 + child.visit_count))
#             if ucb_value > best_value:
#                 best_value = ucb_value
#                 best_action = action
#         return best_action, node.children[best_action]

#     def expand(self, node, state, legal_actions):
#         """Expand the tree by adding all legal actions as children."""
#         input_tensor = torch.tensor(state, dtype=torch.float32).unsqueeze(0)
#         with torch.no_grad():
#             policy, _ = self.model(input_tensor)
#         policy = policy.squeeze(0).numpy()

#         for action in legal_actions:
#             if action not in node.children:
#                 child = MCTSNode(state)
#                 child.prior = policy[action]
#                 node.children[action] = child

#     def simulate(self, state):
#         """Simulate a rollout and return the value from the value network."""
#         input_tensor = torch.tensor(state, dtype=torch.float32).unsqueeze(0)
#         with torch.no_grad():
#             _, value = self.model(input_tensor)
#         return value.item()

#     def backup(self, path, value):
#         """Backup the value to all nodes in the path."""
#         for node in path:
#             node.visit_count += 1
#             node.total_value += value

#     def run(self, root_state, legal_actions, num_simulations=50):
#         """Run MCTS from the root state."""
#         if root_state not in self.nodes:
#             self.nodes[root_state] = MCTSNode(root_state)
#         root = self.nodes[root_state]

#         for _ in range(num_simulations):
#             node = root
#             path = [node]

#             # Selection
#             while node.children:
#                 action, node = self.select(node)
#                 path.append(node)

#             # Expansion
#             self.expand(node, node.state, legal_actions)

#             # Simulation
#             value = self.simulate(node.state)

#             # Backup
#             self.backup(path, value)

#         # Return the best action based on visit counts
#         best_action = max(root.children.items(), key=lambda item: item[1].visit_count)[0]
#         return best_action

# # Training loop
# def train_model(model, optimizer, num_iterations, legal_actions_fn, reward_fn, state_generator):
#     """Train the model using self-play and reinforcement learning."""
#     mcts = MCTS(model)
#     for iteration in range(num_iterations):
#         # Generate initial state
#         state = state_generator()

#         # Self-play to generate training data
#         states, actions, rewards = [], [], []
#         for _ in range(50):  # Fixed number of steps in an episode
#             legal_actions = legal_actions_fn(state)
#             action = mcts.run(state, legal_actions)
#             states.append(state)
#             actions.append(action)

#             # Apply the action to transition to the next state
#             next_state, reward, done = reward_fn(state, action)
#             rewards.append(reward)

#             if done:
#                 break
#             state = next_state

#         # Compute returns for value training
#         returns = [sum(rewards[i:] * (0.99 ** np.arange(len(rewards) - i))) for i in range(len(rewards))]

#         # Update the neural network
#         optimizer.zero_grad()
#         for state, action, return_value in zip(states, actions, returns):
#             input_tensor = torch.tensor(state, dtype=torch.float32).unsqueeze(0)
#             policy, value = model(input_tensor)

#             # Compute loss
#             target_policy = torch.zeros_like(policy)
#             target_policy[0, action] = 1.0
#             policy_loss = -torch.sum(target_policy * torch.log(policy))
#             value_loss = (value - return_value) ** 2

#             loss = policy_loss + value_loss
#             loss.backward()
#         optimizer.step()

# # Example usage
# if __name__ == "__main__":
#     input_dim = 10  # Example input dimensions (e.g., code features + error context)
#     hidden_dim = 128
#     action_dim = 5  # Example action space (e.g., possible prompts)

#     model = PromptNet(input_dim, hidden_dim, action_dim)
#     optimizer = optim.Adam(model.parameters(), lr=0.001)

#     def dummy_legal_actions_fn(state):
#         return list(range(action_dim))

#     def dummy_reward_fn(state, action):
#         next_state = state
#         reward = random.random() * 2 - 1  # Random reward for example
#         done = random.random() < 0.1  # Randomly end episode
#         return next_state, reward, done

#     def dummy_state_generator():
#         return np.random.rand(input_dim)  # Random initial state

#     train_model(model, optimizer, num_iterations=100, legal_actions_fn=dummy_legal_actions_fn, reward_fn=dummy_reward_fn, state_generator=dummy_state_generator)















# import numpy as np
# import random
# import pandas as pd
# import math
# from collections import defaultdict

# class Node:
#     """Represents a node in the MCTS tree."""
#     def __init__(self, prompt, error_message, parent=None):
#         self.prompt = prompt  # The current prompt
#         self.error_message = error_message  # Current error message
#         self.parent = parent  # Parent node
#         self.children = []  # List of child nodes
#         self.visits = 0  # Number of times this node was visited
#         self.value = 0  # Value of this node (reward-based)
    
#     def is_fully_expanded(self):
#         """Check if the node has been fully expanded."""
#         return len(self.children) > 0
    
#     def best_child(self, exploration_weight=1.0):
#         """Select the best child using UCT (Upper Confidence Bound)."""
#         if not self.children:
#             return None
#         return max(self.children, key=lambda c: c.value / (c.visits + 1e-5) + exploration_weight * math.sqrt(math.log(self.visits + 1) / (c.visits + 1e-5)))

# class MCTS:
#     """Monte Carlo Tree Search algorithm to optimize prompts."""
#     def __init__(self, dataset, max_iterations=1000, exploration_weight=1.4):
#         self.dataset = dataset
#         self.max_iterations = max_iterations
#         self.exploration_weight = exploration_weight
#         self.root = None

#     def select(self, node):
#         """Traverse the tree using UCB1 to select the best node to expand."""
#         while node.is_fully_expanded():
#             node = node.best_child(self.exploration_weight)
#         return node

#     def expand(self, node):
#         """Expand the tree by adding a new child node with a modified prompt."""
#         new_sample = self.dataset.sample(1).iloc[0]
#         new_prompt = new_sample["prompt"]
#         new_error = new_sample["error_message"]

#         child_node = Node(new_prompt, new_error, parent=node)
#         node.children.append(child_node)
#         return child_node

#     def simulate(self, node):
#         """Perform a rollout (simulation) from this node to estimate reward."""
#         prompt = node.prompt
#         error_message = node.error_message

#         # Assign reward based on error correction
#         if error_message == "None":
#             return 10  # Fully correct
#         elif error_message == node.parent.error_message if node.parent else None:
#             return -1  # No improvement
#         else:
#             return 5  # Partial improvement

#     def backpropagate(self, node, reward):
#         """Update the tree with rewards from the simulation."""
#         while node:
#             node.visits += 1
#             node.value += reward
#             node = node.parent

#     def run(self, initial_prompt, initial_error):
#         """Run MCTS for optimizing the prompt sequence."""
#         self.root = Node(initial_prompt, initial_error)
        
#         for _ in range(self.max_iterations):
#             node = self.select(self.root)  # Selection
#             child = self.expand(node)  # Expansion
#             reward = self.simulate(child)  # Simulation
#             self.backpropagate(child, reward)  # Backpropagation

#         return self.root.best_child(0).prompt  # Best optimized prompt

