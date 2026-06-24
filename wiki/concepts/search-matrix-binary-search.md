---
title: "Search Matrix - Binary Search on Flattened 2D Array"
type: concept
tags: [algorithm, binary-search, leetcode, matrix]
created: 2026-06-23
updated: 2026-06-23
---

# Search Matrix (LeetCode)

## Problem
m × n の 2D 行列が与えられる。各行は昇順ソートされており、前の行の最後の要素より次の行の最初の要素が大きい。O(log(m × n)) で target が存在するか判定せよ。

## Solution: Binary Search on Flattened Index

行列を物理的に平坦化してもソート性が維持されることを利用。

```cpp
class Solution {
public:
    bool searchMatrix(vector<vector<int>>& matrix, int target) {
        int ROWS = matrix.size(), COLS = matrix[0].size();

        int l = 0, r = ROWS * COLS - 1;
        while (l <= r) {
            int m = l + (r - l) / 2;
            int row = m / COLS, col = m % COLS;
            if (target > matrix[row][col]) {
                l = m + 1;
            } else if (target < matrix[row][col]) {
                r = m - 1;
            } else {
                return true;
            }
        }
        return false;
    }
};
```

```python
class Solution:
    def searchMatrix(self, matrix: List[List[int]], target: int) -> bool:
        ROWS, COLS = len(matrix), len(matrix[0])

        l, r = 0, ROWS * COLS - 1
        while l <= r:
            m = l + (r - l) // 2
            row, col = m // COLS, m % COLS
            if target > matrix[row][col]:
                l = m + 1
            elif target < matrix[row][col]:
                r = m - 1
            else:
                return True
        return False
```

## Key Insight

| 物理 Index | 行列座標 |
|-----------|---------|
| `m` | `row = m // COLS, col = m % COLS` |

行列入りを flat index に変換해도大小關係不變（矩陣的全局排序特性）。

## Complexity

| | |
|--|--|
| Time | O(log(m × n)) |
| Space | O(1) |

## Alternative: 兩端收斂

```python
# 另一種寫法：從右上角出發
def searchMatrix(matrix, target):
    ROWS, COLS = len(matrix), len(matrix[0])
    r, c = 0, COLS - 1
    while r < ROWS and c >= 0:
        if matrix[r][c] == target:
            return True
        elif matrix[r][c] > target:
            c -= 1
        else:
            r += 1
    return False
```

## Related
- [[binary-search-template]]（二分搜尋通用模板）
- [[matrix-traversal-patterns]]（矩陣遍歷模式）
