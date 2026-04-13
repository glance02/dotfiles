# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

CFF+EMOFIM 是一个公平影响力最大化（Fair Influence Maximization）研究项目，结合 CFF（Community Fair with concave Function）模型与进化多目标优化算法（NSGA-II 变体），在社交网络上同时最大化影响力传播和最小化群体间效用方差。

**双目标优化**：最大化 σ'(S)（归一化影响力），最小化 x_var（群体效用方差）

## 运行命令

```bash
python main.py              # 主入口，在 __main__ 中取消注释选择实验
python draw_graphs.py       # 绘制结果图表
python DataProcess_mine.py  # 处理实验结果（计算 RoF、PoF、F-score）
```

无构建步骤、无测试框架、无 requirements.txt。

## 核心依赖

- **NetworkX** — 图数据结构
- **NumPy** — 数值计算
- **igraph** (python-igraph) — GML 格式图读取（`LoadData.py` 中的 `load_graph_based_on_igraph`）
- **tqdm** — 进度条
- **matplotlib** — 可视化
- **xlwt** — Excel 导出

## 架构

### 数据模型层

- **[graph.py](graph.py)** — `Node`（ID + 激活状态）、`Community`（cID + 成员列表）、`Communities`（社区集合 + node→cID 映射）、`graph`（封装 NetworkX 图 + 节点/社区信息）

### 数据加载层

- **[LoadData.py](LoadData.py)** — 两种加载路径：
  - `load_graph(edges_file, community_file)` — 从 txt 边列表 + 社区文件加载（karate、email 数据集）
  - `load_graph_based_on_igraph(gml_path, attribute)` — 从 GML 文件按指定属性加载社区划分（networks_gml 数据集）

### 算法层

- **[CFF_model.py](CFF_model.py)** — `IMM` 类，影响力最大化核心：
  - `generate_RRs()` — 生成反向可达集（Reverse Reachable Set）
  - `NodeSelection()` — 标准 IMM 贪心种子选择
  - `CELF_community_fair_NodeSelection()` — 基于社区凹函数的公平种子选择（CELF 加速）
  - `concave_function()` — 7 种凹函数类型（0: 对数、1: 幂、2: 指数、3: 抛物线根、4: 正弦、5: 抛物线、6: 线性补偿）
  - `ap2utility()` — 激活概率→群体效用转换
  - `multi_process_MC_InfEst()` — 多进程蒙特卡洛影响力估计

- **[EMO.py](EMO.py)** — `emo` 类（原始版本），NSGA-II 进化多目标优化：
  - `fair_nsga2()` — 主循环：种群初始化 → T 轮演化（目标计算 → 非支配排序 → 自适应比率 → 交叉/变异 → 合并选择）
  - `make_new_fair_pop()` — 公平感知的种群生成（F0 fronts 优先交叉 + fair_mutation 奖惩变异）
  - `fair_mutation()` — 按群体效用缺口概率采样变异
  - `adapt_ratio_by_distance()` — 根据拥挤距离自适应调节 `fc_ratio` 和 `fm_p`
  - `gen_B()` — 为每个社区构建候选节点集

- **[EMO2.py](EMO2.py)** — `emo` 类（改进版本），与 EMO.py 的关键差异：
  - `init_get_influence_matrix()` 同时构建 `self.B`（带权重的社区候选节点字典），替代 EMO.py 中的 `gen_B()` 列表
  - `fair_mutation()` 使用 B 的权重进行加权随机采样，而非均匀随机
  - `make_new_fair_pop()` 不再传入 B 参数，直接使用 `self.B`

### 实验入口

- **[main.py](main.py)** — 多个实验函数：
  - `main_EMO_email()` — 在 email 数据集上运行 EMO 算法
  - `main_CFF_networksgml()` / `main_IMM_networksgml()` — 在 networks_gml（24 个合成图）上运行 CFF/IMM
  - `main_CFF_karate()` / `main_IMM_karate()` / `main_DC_karate()` — 在 karate 数据集上运行各算法
  - `create_gml_file()` — 将 txt 格式转换为 GML 格式
  - `multi_generate_RRs()` — 多进程并行生成 RR sets

### 结果分析层

- **[Cal_HV.py](Cal_HV.py)** — 每代 HV（Hypervolume）计算与保存
- **[Measure.py](Measure.py)** — `resultData` 类，结果数据封装（含 HV 计算、JSON 序列化）
- **[DataProcess_mine.py](DataProcess_mine.py)** — 批量计算 RoF（Reward of Fairness）、PoF（Price of Fairness）、F-score
- **[draw_graphs.py](draw_graphs.py)** — 绘制 Pareto 前沿散点图和 HV 热力图

## 数据目录结构

```
data/
├── karate/          # Karate Club（34 节点，小规模测试）
│   ├── karate.txt        # 边列表
│   ├── karate_com.txt    # 社区划分
│   └── karate.gml        # GML 格式
├── email/           # Email Eu Core（~1000 节点）
├── networks_gml/    # 合成图 ×24（500 节点，属性：gender/ethnicity/age）
├── uvm/             # UVM 网络
└── youtube/         # YouTube 网络（大规模）
```

## 关键参数说明

| 参数 | 含义 | 典型值 |
|------|------|--------|
| `k` | 种子集大小 | 5-25 |
| `p` / `probability` | IC 模型传播概率 | 0.01-0.1 |
| `N` | 种群数量 | 20-100 |
| `T` | 演化代数 | 20-200 |
| `c_p` | 交叉概率 | 0.75 |
| `m_p` | 变异概率 | 0.2 |
| `fc_ratio` | F0 fronts 优先交叉比率（自适应） | 初始 1.0 |
| `fm_p` | 公平变异概率（自适应） | 初始 1.0 |
| `graph_type` | 0=无向图, 1=有向图 | — |
| `concave_function_type` | 凹函数类型（0-6） | 常用 2 |
| `function_parameter` | 凹函数参数 | 如 40 |

## EMO 与 EMO2 的选择

当前 `main.py` 使用 `from EMO2 import emo`。EMO2 是 EMO 的改进版本，主要区别在于 fair_mutation 使用基于 RR set 覆盖频率的加权采样替代均匀随机采样。两个文件中的 `emo` 类名相同，切换时只需修改 import。

## 结果输出

- `result/` — EMO 实验结果（JSON 格式，按代存储 Pareto 前沿和 HV）
- `result2/` — CFF/IMM 对比实验结果
- `CFF_result/` / `IMM_result/` — 各算法种子集结果
