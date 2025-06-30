########################################################################
#                                                                      #
#                      PISA 2018 - Finlândia                           #        
#                                                                      #
#        André Silvestre Nº104532 | Diogo Catarino Nº104745            #
#     Francisco Gomes Nº104944 | Maria Margarida Pereira Nº 105877     #
#                      Rita Matos Nº104936                             #
#                                                                      #
########################################################################

 
# install.packages('pacman')
pacman::p_load(haven,corrplot,psych,tibble,DT,flextable,dplyr,mice, skimr, cluster, mclust, ggplot2)
options(max.print = 10000) # Opção para ver toda a informação
set.seed(123)              # Definir um set.seed para permitir reprodutibilidade de resultados

# Ler o dataset em formato .rds
PISA <- readRDS("STU_QQQ_5.rds")

# Estrutura do dataset
print(paste("Nº de Observações:", nrow(PISA)))
print(paste("Nº de Colunas:", ncol(PISA)))

# Extrair os dados da Finlância e Remover a variável 'CNT'
str(PISA$CNT)               # FIN | Finland
PISA_FIN <- subset(PISA, CNT == "FIN")
PISA_FIN <- subset(PISA_FIN, select = -c(CNT))
dim(PISA_FIN)
# View(PISA_FIN)

# Verificar duplicados
# sum(duplicated(PISA_FIN)) # Não tem
 
# Observação das Primeiras Observações
head(PISA_FIN)

# Frequências absolutas, relativa e proporção acumulada dos NAs nas variáveis
Col_NA <- data.frame(
  Frequencia_Absoluta = colSums(is.na(PISA_FIN)),
  Frequencia_Relativa = round(colSums(is.na(PISA_FIN))/nrow(PISA_FIN),2)
)
Col_NA <- setNames(Col_NA, c("n", "p"))
Col_NA

# Selecionar as colunas que têm menos de 60% de valores omissos
PISA_FIN <- PISA_FIN[, colSums(is.na(PISA_FIN)) < .6*nrow(PISA_FIN)]
dim(PISA_FIN) # 104 var -> 71 var   


# Nº de Colunas restantes e Nº de NAs nessas Colunas
ncol(PISA_FIN)
colSums(is.na(PISA_FIN))

# Nº de Observações e Nº de NAs nessas Observações
nrow(PISA_FIN)
table(rowSums(is.na(PISA_FIN)))

# Frequências absolutas, relativa e proporção acumulada dos NAs nas observações
Row_NA <- data.frame(
  Frequencia_Absoluta = table(rowSums(is.na(PISA_FIN))),
  Frequencia_Relativa = round(prop.table(table(rowSums(is.na(PISA_FIN)))),2),
  Percentagem_Acumulada = round((cumsum(prop.table(table(rowSums(is.na(PISA_FIN)))))),2)
)[,c(2,4,5)]
Row_NA <- setNames(Row_NA, c("n", "p", "p Acumulada"))
Row_NA

# Heurística - Eliminar Observações que tenham + de 20 var. com valores omissos
PISA_FIN <- PISA_FIN[rowSums(is.na(PISA_FIN)) < 20, ]
dim(PISA_FIN) # 5649 obs. -> 5249 obs.   

# ------------------------------------------------------------------------------

# Eliminar NAs
PISA_FIN_sem_NAs <- na.omit(PISA_FIN)
dim(PISA_FIN_sem_NAs)
# PISA_FIN <- PISA_FIN_sem_NAs

# ------------------------------------------------------------------------------

# Remover atributos "haven_labelled" para evitar erros na função 'mice()'
PISA_FIN <- haven::zap_labels(PISA_FIN)

# Imputar os NAs com Regressão Linear
# NA_imputed_linear <- mice(PISA_FIN, method = "pmm")
# PISA_FIN_with_NAs_imputed_linear <- complete(NA_imputed_linear,1)

# Imputar os NAs com Random Forest
NA_imputed_rf <- mice(PISA_FIN, method = "rf")
PISA_FIN_with_NAs_imputed_rf <- complete(NA_imputed_rf,1)

# Comparar os 2 datasets imputados
# summary(PISA_FIN_with_NAs_imputed_linear)
summary(PISA_FIN_with_NAs_imputed_rf)

# Verificar NAs
# sum(is.na(PISA_FIN_with_NAs_imputed_linear))
sum(is.na(PISA_FIN_with_NAs_imputed_rf))

# Atribuir o Conjunto de Dados Imputado
# PISA_FIN_with_NAs <- PISA_FIN_with_NAs_imputed_linear
PISA_FIN_with_NAs <- PISA_FIN_with_NAs_imputed_rf
PISA_FIN <- PISA_FIN_with_NAs


# ------------------------------------------------------------------------------

# Lista de variáveis de PROFILE
PROFILE_vars <- c("AGE", "IMMIG","ESCS", "HISEI", "BFMJ2", "BMMJ1", "HISCED", "FISCED",
                  "MISCED", "ISCEDL", "PROGN", "OCOD1","OCOD2","OCOD3", "ST004D01T")

# Lista de variáveis de INPUT
INPUT_vars <- names(PISA_FIN)[!names(PISA_FIN) %in% PROFILE_vars]

# Selecionar apenas as colunas relevantes do dataset
PISA_INPUT <- PISA_FIN_with_NAs[, INPUT_vars]
PISA_PROFILE <- PISA_FIN_with_NAs[, PROFILE_vars]

# Para testar com o datset sem NAs
# PISA_INPUT <- PISA_FIN_sem_NAs[, INPUT_vars]
# PISA_PROFILE <- PISA_FIN_sem_NAs[, PROFILE_vars]


# ====================== A N Á L I S E    P R O F I L E ========================

# Palette Colorblind-Friendly - https://stackoverflow.com/questions/57153428/r-plot-color-combinations-that-are-colorblind-accessible
colorBlindGrey8   <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
scales::show_col(colorBlindGrey8)

# Gráfico de Barras para FISCED e MISCED
df <- data.frame( Education = c("None", "ISCED 1", "ISCED 2", "ISCED 4", "ISCED 5","ISCED 6"),
  Mãe = c(sum(PISA_PROFILE$FISCED == 0), sum(PISA_PROFILE$FISCED == 1), sum(PISA_PROFILE$FISCED == 2), sum(PISA_PROFILE$FISCED == 4), sum(PISA_PROFILE$FISCED == 5), sum(PISA_PROFILE$FISCED == 6)),
  Pai = c(sum(PISA_PROFILE$MISCED == 0), sum(PISA_PROFILE$MISCED == 1), sum(PISA_PROFILE$MISCED == 2), sum(PISA_PROFILE$MISCED == 4), sum(PISA_PROFILE$MISCED == 5), sum(PISA_PROFILE$MISCED == 6))
)

barplot(t(as.matrix(df[, 2:3])), beside = TRUE, 
        names.arg = df$Education,
        ylim = c(0,3000),
        col = c("#CC79A7", "#56B4E9"),
        legend.text = TRUE,
        ylab = "n",
        xlab = "Nível de Educação",
        main = 'Escolaridade dos Pais',
        args.legend = list(x = "topleft", bty = "n", inset=c(0.05, 0.1))
        )


# Tabela de Frequências da variáveis 'FISCED' e 'MISCED'
ISCED <- c("None", "ISCED 1", "ISCED 2", "ISCED 4", "ISCED 5","ISCED 6")
table3 <- data.frame(ISCED, Pai_ISCED_n = as.vector(table(PISA_PROFILE$FISCED)), Pai_ISCED_p = as.vector(round((prop.table(table(PISA_PROFILE$FISCED))),2)), Mae_ISCED_n = as.vector(table(PISA_PROFILE$MISCED)), Mae_ISCED_p = as.vector(round((prop.table(table(PISA_PROFILE$MISCED))),2)))
ftable_3 <- flextable(head(table3))

ftable_3 <- bg(ftable_3, bg = "#0072B2", part = "header")
ftable_3 <- color(ftable_3, color = "white", part = "header")
ftable_3 <- bold(ftable_3, bold = TRUE, part="header")
ftable_3 <- set_header_labels(ftable_3,ISCED = 'ISCED',Pai_ISCED_n = 'Pai (n)',Pai_ISCED_p = 'Pai (p)', Mae_ISCED_n = 'Mãe (n)', Mae_ISCED_p = 'Mãe (p)')
(ftable_3 <- autofit(ftable_3))

# Gráfico de Dispersão BFMJ2 e BMMJ1 - Índice de Situação Ocupacional dos pais
df2 <- data.frame(Mãe = PISA_PROFILE$BMMJ1, Pai = PISA_PROFILE$BFMJ2)

boxplot(df2,
        ylim = c(0,100),
        col = c("#CC79A7", "#56B4E9"),
        ylab = "Índice de Situação Ocupacional",
        main = 'ISO dos Pais'
        )

# ========================= A N Á L I S E     P C A ============================

# ScatterPlot
pairs(PISA_INPUT, pch = 19, lower.panel = NULL)

# Análise Descritiva das Variáveis
skim(PISA_INPUT)
summary(PISA_INPUT)

# CorrPlot - Gráfico de Correlação
correlation <- cor(PISA_INPUT)
par(oma = c(.1, .1, .1, .1)) # space around for text
corrplot.mixed(correlation, 
               order = "hclust",     # Ordem das variáveis
               tl.pos = "lt",        # Texto à esquerda + topo
               upper = "ellipse",
               tl.cex = 0.5,         # Tamanho do texto
               tl.col = "black",     # Cor do texto
               number.cex = 0.3,     # Tamanho dos Valores
               addgrid.col = "white" # Remover a grade
               )


# Remover a variável 'ST001D01T' da Matriz de Correlação e do PISA_INPUT
# uma vez que têm correlação perfeita - ST001D01T deriva de GRADE
correlation <- correlation[-which(colnames(correlation) == 'ST001D01T'), -which(colnames(correlation) == 'ST001D01T')]
PISA_INPUT <- subset(PISA_INPUT, select = -ST001D01T)

# Matriz de Correlação
round(correlation, 3)

# Remover variáveis com correlações fracas
PISA_INPUT <- subset(PISA_INPUT, select = -c(BEINGBULLIED,GFOFAIL,PERCOOP,REPEAT,PISADIFF,SCREADDIFF,ICTSCH,GRADE,ST060Q01NA))
correlation <- cor(PISA_INPUT)

# Teste de Bartlett - H0: P = I (Matriz de Correlação = Matriz Identidade)
cortest.bartlett(correlation)

# KMO
kmo <- KMO(correlation)
kmo

# Escolher variáveis que tenham + de 0.6 de KMO - Remover as restantes
selected_vars <- names(kmo$MSAi[kmo$MSAi > 0.6])
selected_vars
PISA_INPUT <- subset(PISA_INPUT, select = selected_vars)

# Estandardização dos dados
dataZ <- scale(PISA_INPUT)

# Suponha que o Nº de componentes (nfatores) = Nº de variáveis, ou seja, D = 37,
# Começamos por ver sem rotação
pc37 <- principal(dataZ, nfactors=ncol(PISA_INPUT), rotate="none", scores=TRUE)  
pc37

# Kaiser criterion
round(pc37$values,3)
# 9 PCAs

# Screeplot - Encontrar o 'cotovelo'
plot(pc37$values, 
     type = "b", 
     main = "Scree plot for PISA 2018 dataset",
     xlab = "Number of PC", 
     ylab = "Eigenvalue",
     xlim = c(0, 15)  # Limitámos a visualização a 15 PCs
)

# Valores selecionados pelo ScreePlot para nº de PCAs
abline(v = 7, col = "#004C95", lty = 2)
abline(v = 9, col = "#002060", lty = 2)

# Adicionar Números de PC adequados
text(7.15, pc37$values[7], labels = "7", pos = 3, col = "#004C95")
text(9.15, pc37$values[9], labels = "9", pos = 3, col = "#002060")


# Variância Acumulada Explicada
pc37$loadings
# 9 PCAs

# Contudo devido à dificuldade de observar as principais variáveis da componente, vamos rotacioná-la
pc37 <- principal(dataZ, nfactors=ncol(PISA_INPUT), rotate="varimax", scores=TRUE)  
pc37

# PCA com Nº de PCs = 7
pc7 <- principal(dataZ, nfactors=7, rotate="varimax")
pc7$loadings

round(pc7$communality,2)

# PCA com Nº de PCs = 9
pc9 <- principal(dataZ, nfactors=9, rotate="varimax")
pc9$loadings

round(pc9$communality,2)

# Adicionar as Variáveis PCAs com esses Scores com 9 PC
PISA_INPUT$PC1_TE <-  pc9$scores[,1]    # Teacher's Engagement [TE]: Reflete o nível de envolvimento dos professores no processo de aprendizagem.
PISA_INPUT$PC2_AP <-  pc9$scores[,2]    # Academic Performance [AP]: Avalia o desempenho académico dos alunos em Literatura, Matemática e Ciências.
PISA_INPUT$PC3_SMW <- pc9$scores[,3]   # Student's Mental Well-being [SMW]: Analisa o estado de bem-estar mental dos alunos.
PISA_INPUT$PC4_SIR <- pc9$scores[,4]   # Student-ICT Relation [SIR]: Avalia a interação dos alunos com as TIC.
PISA_INPUT$PC5_DAR <- pc9$scores[,5]   # Digital Access and Resources [DAR]: Expressa o acesso dos alunos a recursos digitais.
PISA_INPUT$PC6_IU <-  pc9$scores[,6]    # ICT Use [IU]: Avalia a utilização das TIC em sala de aula e em casa.
PISA_INPUT$PC7_ATSL <-pc9$scores[,7]  # Attitudes towards School and Learning [ATSL]: Explora as atitudes dos alunos em relação à escola.
PISA_INPUT$PC8_CiS <- pc9$scores[,8]   # Competition in School [CiS]: Analisa a presença e o impacto da competição entre os alunos no ambiente escolar.
PISA_INPUT$PC9_DLE <- pc9$scores[,9]   # Digital Learning Enrichment [DLE] Refere-se ao uso de tecnologias digitais para enriquecer a experiência de aprendizagem dos alunos.


# ScatterPlot das Componentes PC1 vs PC2 
plot(PISA_INPUT$PC1_TE, PISA_INPUT$PC2_AP , pch = 19,xlim = c(-3,3), ylim = c(-3,3),
     xlab="Teacher's Engagement [TE]", ylab="Academic Performance [AP]", main = "Scores: PC1 vs PC2")

# ScatterPlot das Componentes PC3 vs PC2 
plot(PISA_INPUT$PC3_SMW, PISA_INPUT$PC2_AP , pch = 19,xlim = c(-3,3), ylim = c(-3,3),
     xlab="Student's Mental Well-being [SMW]", ylab="Academic Performance [AP]", main = "Scores: PC3 vs PC2")

# ScatterPlot das Componentes PC4 vs PC6 
plot(PISA_INPUT$PC4_SIR, PISA_INPUT$PC6_IU , pch = 19,xlim = c(-3,3), ylim = c(-3,3),
     xlab="Student-ICT Relation [SIR]", ylab="Academic Performance [AP]", main = "Scores: PC4 vs PC6")



# ================== A N Á L I S E     C L U S T E R I N G =====================

# -----------------------
#  Hierarchical Cluster
# -----------------------
pc_dist <- dist(PISA_INPUT[,38:46])

# Cluster Hierárquico com o método "ward.D2"
hclust  <- hclust(pc_dist, method='ward.D2')
plot(hclust, hang=-1, labels=FALSE) 

# Corte do Dendograma em 5 clusters
groups.k5 <- cutree(hclust, k=5)
rect.hclust(hclust, k=5, border="red") 

# Silhouette
plot(silhouette(groups.k5, pc_dist))
# Com base no dendrograma, selecionámos 5 clusters
# A silhueta mostra uma separação quase inexistente

# Cluster Hierárquico com o método "complete"
hclust  <- hclust(pc_dist,method='complete')
plot(hclust, hang=-1, labels=FALSE)

# Corte do Dendograma em 3 clusters
groups.k3_c <- cutree(hclust, k=3)
rect.hclust(hclust, k=3, border="red")

# Silhouette
plot(silhouette(groups.k3_c, pc_dist))

# Crosstab
table(groups.k5,groups.k3_c)

# -----------------------
#       K-Means
# -----------------------

# K-Means: nº de clusters
wssplot <- function(xx, nc=15, seed=1234){
  wss <- (nrow(xx)-1)*sum(apply(xx,2,var))
  for (i in 2:nc){
    set.seed(seed)
    wss[i] <- sum(kmeans(xx, centers=i)$withinss)}
  plot(1:nc, wss, type="b", xlab="Number of Clusters",
       ylab="Within groups sum of squares")}
wssplot(PISA_INPUT[,38:46], nc=10)

# Valor selecionados pelo Wssplot para nº de clusters
abline(v = 5, col = "#004C95", lty = 2)
text(5.15, 37000, labels = "5", pos = 3, col = "#002060")

# K-means cluster com K=5
kmeans.k5 <- kmeans(PISA_INPUT[,38:46], 5)
kmeans.k5$size   # Nº de Observações em cada cluster
PISA_INPUT = PISA_INPUT %>% mutate(cluster = kmeans.k5$cluster)


# Silhouette
plot(silhouette(kmeans.k5$cluster,pc_dist))

# Crosstab
table(groups.k5, PISA_INPUT$cluster)

# Gráfico de barras do score médio de cada PC em cada cluster
barplot(colMeans(subset(PISA_INPUT,cluster==1)[,38:46]),main= "Cluster 1 - Average score in each principal component", ylim = c(-2,2))
barplot(colMeans(subset(PISA_INPUT,cluster==2)[,38:46]),main= "Cluster 2 - Average score in each principal component", ylim = c(-2,2))
barplot(colMeans(subset(PISA_INPUT,cluster==3)[,38:46]),main= "Cluster 3 - Average score in each principal component", ylim = c(-2,2))
barplot(colMeans(subset(PISA_INPUT,cluster==4)[,38:46]),main= "Cluster 4 - Average score in each principal component", ylim = c(-2,2))
barplot(colMeans(subset(PISA_INPUT,cluster==5)[,38:46]),main= "Cluster 5 - Average score in each principal component", ylim = c(-2,2))

# Gráfico de Barras da distribuição de gênero (variáviel ST004D01T), por cluster
PISA_Cluster <- data.frame(PISA_INPUT[,38:47], PISA_PROFILE[,c(3,4,15)])

barplot(prop.table(table(subset(PISA_Cluster,cluster==1)[,13])),main= "Cluster 1 vs. Gender", ylim = c(0,.7))
barplot(prop.table(table(subset(PISA_Cluster,cluster==2)[,13])),main= "Cluster 2 vs. Gender", ylim = c(0,.7))
barplot(prop.table(table(subset(PISA_Cluster,cluster==3)[,13])),main= "Cluster 3 vs. Gender", ylim = c(0,.7))
barplot(prop.table(table(subset(PISA_Cluster,cluster==4)[,13])),main= "Cluster 4 vs. Gender", ylim = c(0,.7))
barplot(prop.table(table(subset(PISA_Cluster,cluster==5)[,13])),main= "Cluster 5 vs. Gender", ylim = c(0,.7))

# Calcula as proporções do Género dos Estudantes para cada cluster
Genero_Cluster <- data.frame(G = c("Female","Male"),C1 = as.vector(round(prop.table(table(subset(PISA_Cluster, cluster == 1)[, 13])), 2)), C2=as.vector(round(prop.table(table(subset(PISA_Cluster, cluster == 2)[, 13])), 2)), C3=as.vector(round(prop.table(table(subset(PISA_Cluster, cluster == 3)[, 13])), 2)), C4=as.vector(round(prop.table(table(subset(PISA_Cluster, cluster == 4)[, 13])), 2)), C5=as.vector(round(prop.table(table(subset(PISA_Cluster, cluster == 5)[, 13])), 2)))
ftable_GC <- flextable(head(data.frame(Genero_Cluster)))
ftable_GC <- bg(ftable_GC, bg = "#0072B2", part = "header")
ftable_GC <- color(ftable_GC, color = "white", part = "header")
ftable_GC <- bold(ftable_GC, bold = TRUE, part="header")
ftable_GC <- set_header_labels(ftable_GC, G = "Gender" ,C1= "Cluster 1", C2= "Cluster 2", C3= "Cluster 3", C4= "Cluster 4", C5= "Cluster 5")
(ftable_GC <- autofit(ftable_GC))



# Fonte do Código do Gráfico Seguinte -> https://cimentadaj.github.io/ml_socsci/unsupervised-methods.html#k-means-clustering
# Visualização do Scatterplot que demonstra a distribuição dos clusters nas variáveis ESCS e HISEI
res <-
  PISA_Cluster %>%
  select(ESCS, HISEI) %>%
  kmeans(centers = 5)

PISA_Cluster$clust <- factor(res$cluster, levels = 1:5, ordered = TRUE)

PISA_Cluster %>%
  ggplot(aes(ESCS, HISEI, color = clust)) +
  geom_point(alpha = 1/5) +
  scale_x_continuous("Índice de Situação Econômica, Social e Cultural da Família") +
  scale_y_continuous("Índice de Maior Status Ocupacional dos Pais") +
  labs(title = "Relação entre ESCS e HISEI nos clusters") +
  theme_minimal()


# --------------------------
#          PAM
# (Partition Around Medoids)
# --------------------------

pam.k5 <- pam(PISA_INPUT[,38:46], 5)
table(groups.k5,pam.k5$clustering)

# Silhouette
plot(silhouette(pam.k5, pc_dist))

# PCA & Clustering
clusplot(pam.k5, labels = 5, col.p = pam.k5$clustering)

# --------------------------
#  Probabilistic Clustering
# --------------------------
PISA_Probabilistic <- data.frame(PISA_INPUT[,38:46])
                           
# Seleção do modelo
BIC <- mclustBIC(PISA_Probabilistic)
plot(BIC)
BIC

# --------------------------
#          GMM 
#  (Gaussian Mixture Models)
# --------------------------

# Aplicação do GMM com 6 componentes
results.G6 <- Mclust(PISA_Probabilistic, G = 6)
summary(results.G6, parameters = TRUE)

# Resultados
results.G6$modelName                 # Modelo ótimo selecionado
results.G6$G                         # Nº ótimo de clusters
round(head(results.G6$z, 5), 3)      # Probabilidade de pertencer a cada cluster
head(results.G6$classification, 5)   # A que cluster são atribuidas as primeiras 5 observações

plot(results.G6, what = "classification")
plot(results.G6, what = "uncertainty")









############################# A N E X O S ######################################

# ST004D01T - Género do Estudante (1-F | 2-M)
PISA_PROFILE$ST004D01T <- factor(PISA_PROFILE$ST004D01T, labels = c("Female", "Male"))

# Tabela de Frequências do Género dos Estudantes
table0 <- data.frame(G = c("Female", "Male"), n= as.vector(table(PISA_PROFILE$ST004D01T)), p = as.vector(round((prop.table(table(PISA_PROFILE$ST004D01T))),2)))
ftable_0 <- flextable(head(table0))

ftable_0 <- bg(ftable_0, bg = "#0072B2", part = "header")
ftable_0 <- color(ftable_0, color = "white", part = "header")
ftable_0 <- bold(ftable_0, bold = TRUE, part="header")
ftable_0 <- set_header_labels(ftable_0,G = 'Género', n = 'n', p = 'p')
(ftable_0 <- autofit(ftable_0))

# Histograma da variável 'Age'
hist(PISA_PROFILE$AGE, freq=FALSE, main = "Histograma da Variável Idade", xlab='Idade',col = "#999999")
lines(density(PISA_PROFILE$AGE), lwd=2, col='#D55E00')

# Tabela de Frequências com as Variáveis 'ISCEDL' e 'PROGN'
PROGN_ <- factor(PISA_PROFILE$PROGN, levels = c("02460001", "02460003", "02460004"), labels = c("Comprehensive Secondary School (ISCED = 2)","Upper Secondary School (ISCED = 3)" , "Upper Secondary School (ISCED = 3)"))
PROGN <- c("Comprehensive Secondary School (ISCED = 2)","Upper Secondary School (ISCED = 3)")
table1 <- data.frame(PROGN, n = as.vector(table(PROGN_)), p = as.vector(round(prop.table(PROGN_tab),3)))
ftable_1 <- flextable(head(table1))

ftable_1 <- bg(ftable_1, bg = "#0072B2", part = "header")
ftable_1 <- color(ftable_1, color = "white", part = "header")
ftable_1 <- bold(ftable_1, bold = TRUE, part="header")
ftable_1 <- set_header_labels(ftable_1,PROGN = 'Programa de Estudos',n = 'n',p = 'p')
(ftable_1 <- autofit(ftable_1))

# Tabela de Frequências da variável 'IMMIG'
IMMIG <- c("1 | Native Students", "2 | Second-Generation Students", "3 | First-Generation Students")
table2 <- data.frame(IMMIG, n = as.vector(table(PISA_PROFILE$IMMIG)), p = as.vector(round((prop.table(IMMIG_tab)),2)))
ftable_2 <- flextable(head(table2))

ftable_2 <- bg(ftable_2, bg = "#0072B2", part = "header")
ftable_2 <- color(ftable_2, color = "white", part = "header")
ftable_2 <- bold(ftable_2, bold = TRUE, part="header")
ftable_2 <- set_header_labels(ftable_2,PROGN = 'Programa de Estudos',n = 'n',p = 'p')
(ftable_2 <- autofit(ftable_2))

# Histograma com as variáveis 'ESCS'
hist(PISA_PROFILE$ESCS, freq=FALSE, main = "Histograma da Variável ESCS", xlab='ESCS', ylim = c(0,0.6), xlim = c(-3.5,3.5), col = "#999999")
lines(density(PISA_PROFILE$ESCS), lwd=2, col='#D55E00')
