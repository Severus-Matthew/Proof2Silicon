import json
import matplotlib.pyplot as plt

# Load data
with open('/mnt/shared/gpfs/home/manvij2/all_episode_data_with_cumulative.json', 'r') as f:
    data = json.load(f)

# Determine list of records
if isinstance(data, dict):
    records = list(data.values())
else:
    records = data

# Extract rewards
rewards = [rec.get('reward', 0) for rec in records]
rewards = [0.1*r for r in rewards]
episodes = list(range(1, len(rewards) + 1))

# Plot Reward vs Episode
plt.figure()
plt.plot(episodes, rewards)
plt.xlabel('Episode')
plt.ylabel('Reward')
plt.title('Reward vs Episode')
plt.savefig('reward_vs_episode11.png')  
# plt.show()
