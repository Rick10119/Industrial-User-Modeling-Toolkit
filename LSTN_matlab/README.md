### Repository: Linear Industrial Production Process Model for Demand Response

#### English README:

This repository contains data and code related to my research project on a linearized STN model (LSTN: A Linear Model of Industrial Production Process for Demand Response), all developed by me. The main components include:

- **LSTN_model.m**: Optimization program for the optimal energy use problem of a single factory.

- **LSTN_model_aggregated.m**: Given factory parameters, this script constructs the operational constraints model (LSTN) for multiple factories and outputs the Constraints_primal constraints.

- **data_generate_parameters.m**: Generates parameters for multiple factories using data from literature.

- **parameter_Lu_milp.m**: Reads factory parameters from `load_parameters_Lu_milp.xlsx` (parameters from Lu_2021). It also reads market electricity prices and other data.

Please note that the comments in the code are concise. Understanding the implementation may require reading our research paper available at [ResearchGate](https://www.researchgate.net/publication/377827063_LSTN_A_Linear_Model_of_Industrial_Production_Process_for_Demand_Response), rather than relying solely on the code comments.

#### 中文 README:

这个代码库包含了我研究的线性化STN模型（LSTN: A Linear Model of Industrial Production Process for Demand Response）的数据和代码，均由我编写。主要包括以下几个部分：

- **LSTN_model.m**: 单个工厂的最优用能问题的优化程序。

- **LSTN_model_aggregated.m**: 给定工厂参数，构建多个工厂的运行约束（LSTN）模型，并输出Constraints_primal约束。

- **data_generate_parameters.m**: 使用文献中的数据为多个工厂生成参数。

- **parameter_Lu_milp.m**: 从`load_parameters_Lu_milp.xlsx`中读取工厂参数（参数来源于Lu_2021）。同时读取市场电价和其他数据。

请注意，代码中的注释比较简略。理解实现细节可能需要阅读我们在[ResearchGate](https://www.researchgate.net/publication/377827063_LSTN_A_Linear_Model_of_Industrial_Production_Process_for_Demand_Response)上发布的研究论文，而不仅仅依靠代码注释。



