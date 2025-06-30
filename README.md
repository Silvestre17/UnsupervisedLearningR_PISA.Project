# 🎓 PISA 2018 Finland: Unsupervised Learning for Educational Insights 🇫🇮

<p align="center">
  <img src="./img/Finland-Chiropractic-CE.jpeg" alt="PISA 2018 Finland Project Banner" width="800">
</p>

<p align="center">
    <!-- Project Links -->
    <a href="https://github.com/Silvestre17/UnsupervisedLearningMethods_PISA2018.Finland"><img src="https://img.shields.io/badge/Project_Repo-100000?style=for-the-badge&logo=github&logoColor=white" alt="GitHub Repo"></a>
</p>

## 📝 Description

This project conducts an in-depth analysis of the **[PISA 2018](https://www.oecd.org/en/publications/pisa-2018-results-volume-i_5f07c754-en.html) dataset**, with a specific focus on students in **Finland**. Using unsupervised learning techniques, this study aims to uncover the key underlying factors that contribute to student success and to identify distinct student profiles. The methodology involves **Principal Component Analysis (PCA)** for dimensionality reduction followed by various **Clustering** algorithms to segment students into meaningful groups.

## ✨ Objective

The core objective is to answer the question: **"What are the key factors contributing to the success of Finnish students in PISA 2018?"**

To achieve this, we will:
*   Synthesize a large number of variables into a smaller set of meaningful components using PCA.
*   Identify and analyze distinct student profiles (clusters) based on these components.
*   Characterize the resulting clusters using demographic and socioeconomic variables to provide actionable insights for educational policy.

## 🎓 Project Context

This project was developed for the **Métodos de Aprendizagem Não Supervisionada** (*Unsupervised Learning Methods*) course as part of the **[Licenciatura em Ciência de Dados](https://www.iscte-iul.pt/degree/code/0322/bachelor-degree-in-data-science)** (*Bachelor Degree in Data Science*) at **ISCTE-IUL**, during the 2022/2023 academic year (2nd semester of the 2nd year).

## 🗺️ Data Source

The data was sourced from the **Programme for International Student Assessment (PISA) 2018** dataset, provided by the **OECD**.

*   **Dataset:** A subset containing **5,649 observations** for students in Finland.
*   **Variable Split:** The variables were strategically divided into two groups for the analysis:
    *   **`INPUT` Variables:** Features related to student performance and school environment, used as inputs for PCA and Clustering.
    *   **`PROFILE` Variables:** Socioeconomic and demographic features used to characterize and interpret the final clusters.

<p align="center">
    <a href="https://www.oecd.org/pisa/">
        <img src="https://img.shields.io/badge/OECD_PISA-0077C8?style=for-the-badge&logo=oecd&logoColor=white" alt="OECD PISA" />
    </a>
</p>

## 🛠️ Technologies Used

This entire project was implemented in the **R** programming language, leveraging its extensive statistical and visualization packages.

<p align="center">
    <a href="https://www.r-project.org/">
        <img src="https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white" alt="R" />
    </a>
    <a href="https://www.rstudio.com/">
        <img src="https://img.shields.io/badge/RStudio-75AADB?style=for-the-badge&logo=rstudio&logoColor=white" alt="RStudio" />
    </a>
    <a href="https://posit.co/products/enterprise/rmarkdown/">
        <img src="https://img.shields.io/badge/R_Markdown-5178B8?style=for-the-badge&logo=r&logoColor=white" alt="R Markdown" />
    </a>
</p>

---

## ⚙️ Analytical Workflow (CRISP-DM)

The project was structured following the CRISP-DM methodology.

### 1. Data Preparation
*   **Data Cleaning:** Imported the dataset and handled initial inconsistencies. A heuristic was applied to manage a large number of missing values: columns with over 60% missing data and rows with more than 20 missing variables were removed.
*   **Imputation:** To retain as much data as possible, missing values in the remaining cases were imputed using two distinct methods: **Linear Regression** and **Random Forest**.

### 2. Dimensionality Reduction with PCA
The first major modeling step was to reduce the complexity of the `INPUT` variables using Principal Component Analysis.

<p align="center">
    <a href="https://cran.r-project.org/web/packages/psych/index.html">
        <img src="https://img.shields.io/badge/psych-0073B7?style=for-the-badge&logo=r&logoColor=white" alt="psych package" />
    </a>
</p>

*   **Sample Adequacy:** We confirmed the suitability of our data for PCA using:
    *   **Bartlett's Test:** Rejected the null hypothesis, indicating that the variables were correlated and suitable for factor analysis.
    *   **Kaiser-Meyer-Olkin (KMO) Test:** Achieved a global KMO value of **0.74**, indicating that the data was adequate for PCA.
*   **Component Selection:** Based on a consensus of **Kaiser's Criterion**, **Scree Plot** analysis, and **Cumulative Explained Variance** (>60%), we retained **9 Principal Components**.
*   **Rotation:** A **Varimax rotation** was applied to the components to improve their interpretability.

### 3. Clustering & Profile Identification
Using the 9 principal components as inputs, we applied several clustering algorithms to segment the students.

<p align="center">
    <a href="https://cran.r-project.org/web/packages/cluster/index.html">
        <img src="https://img.shields.io/badge/cluster-F8766D?style=for-the-badge&logo=r&logoColor=white" alt="cluster package" />
    </a>
    <a href="https://cran.r-project.org/web/packages/mclust/index.html">
        <img src="https://img.shields.io/badge/mclust-00BA38?style=for-the-badge&logo=r&logoColor=white" alt="mclust package" />
    </a>
</p>

*   **Algorithms Tested:**
    *   **Hierarchical Clustering:** Tested with `Ward` and `complete-linkage` methods, evaluated with the **Silhouette Coefficient**.
    *   **K-Means:** The optimal number of clusters (`k=5`) was determined using the **WSS (Elbow Method)**.
    *   **Partition Around Medoids (PAM):** Also tested with `k=5`.
    *   **Gaussian Mixture Models (GMM):** The best model was selected using the **Bayesian Information Criterion (BIC)**.
*   **Final Model:** **K-Means with 5 clusters** was selected as the final model due to its superior interpretability and the clear, distinct profiles it produced.

### 4. Final Cluster Profiles
The 5 clusters identified were named and described based on their characteristics:

| Cluster | Designation            | Description                                                                                                                              |
| :------ | :--------------------- | :--------------------------------------------------------------------------------------------------------------------------------------- |
| **1**   | **Digital Students**   | Students with a positive attitude towards school and good digital skills, but lower academic performance.                                  |
| **2**   | **Disengaged Students**| Students with low academic performance but strong digital competence and access to digital resources.                                       |
| **3**   | **Non-tech Students**  | Students with moderate mental well-being but low engagement with technology and digital resources.                                          |
| **4**   | **Disconnected Students**| Students with low mental well-being but positive interaction with ICT, though with low usage in and out of school.                        |
| **5**   | **High Achievers**     | Students with outstanding academic performance and high engagement in learning activities, but lower familiarity with ICT resources.          |

## 🚀 How to Run the Solution

1.  **Prerequisites:** Install **R** and **RStudio**.
2.  **Open the Project:** Open the `.Rmd` file in RStudio.
3.  **Install Packages:** Run `install.packages("package_name")` for any missing libraries listed at the beginning of the script.
4.  **Knit Report:** Click the **"Knit"** button in RStudio to execute the code and generate the final HTML/PDF report.

## 👥 Team Members (Group Finland)

*   **André Silvestre** (Nº104532)
*   **Diogo Catarino** (Nº104745)
*   **Francisco Gomes** (Nº104944)
*   **Maria Margarida Pereira** (Nº105877)
*   **Rita Matos** (Nº104936)

## 🇵🇹 Note

This project was developed using Portuguese from Portugal 🇵🇹.