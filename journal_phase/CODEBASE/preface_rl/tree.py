from dataclasses import dataclass
from typing import List, Optional


@dataclass
class TreeNode:
    error_code: str
    error_message: str
    reward: float
    prompt: str
    parent: Optional["TreeNode"]
    children: List["TreeNode"]
    depth: int
    success: bool = False


class ErrorTree:
    def __init__(self, max_depth: int = 7):
        self.root: Optional[TreeNode] = None
        self.max_depth = max_depth
        self.current_node: Optional[TreeNode] = None
        self.successful_path: Optional[List[TreeNode]] = None

    def add_node(
        self,
        error_code: str,
        error_message: str,
        reward: float,
        prompt: str,
        parent: Optional[TreeNode] = None,
    ) -> TreeNode:
        depth = 0 if parent is None else parent.depth + 1
        node = TreeNode(
            error_code=error_code,
            error_message=error_message,
            reward=reward,
            prompt=prompt,
            parent=parent,
            children=[],
            depth=depth,
        )
        if parent:
            parent.children.append(node)
        else:
            self.root = node
        return node

    def get_path_to_node(self, node: TreeNode) -> List[TreeNode]:
        path = []
        current: Optional[TreeNode] = node
        while current:
            path.append(current)
            current = current.parent
        return list(reversed(path))

    def traverse(self) -> List[TreeNode]:
        nodes: List[TreeNode] = []

        def rec(node: TreeNode) -> None:
            nodes.append(node)
            for child in node.children:
                rec(child)

        if self.root:
            rec(self.root)
        return nodes

