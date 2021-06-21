---
title: Heterogeneous Graph Convolutional Networks for Android Malware Detection using Callback-Aware Caller-Callee Graphs
dates:
  publication: xxxx 00, 0000
  currentVersion: xxxx 00, 0000
doi: 10.1109/ACCESS.2017.DOI
author:
  - key: 1
    name: Vinayaka K V
    institution: National Institute Technology Karnataka, Surathkal
    city: Srinivasanagar
    address: Mangaluru, Karnataka, India - 575025
    email: vinayakakv.193it001@nitk.edu.in
    photo: vinayaka.png

  - key: 2
    name: Jaidhar C D
    institution: National Institute Technology Karnataka, Surathkal
    city: Srinivasanagar
    address: Mangaluru, Karnataka, India - 575025
    email: jaidharcd@nitk.edu.in
    photo: jaidhar.jpg

correspondingAuthor:
  name: Vinayaka K V
  email: vinayakakv.193it001@nitk.edu.in

abstract: |
      The popularity of the Android Operating System in the smartphone market has given rise to lots of Android malware.
      To accurately detect these malware, many of the existing works use machine learning and deep learning-based methods,
      in which feature extraction methods were used to extract fixed-size feature vectors using the files present inside the Android Application Package (APK).
      Recently, Graph Convolutional Network (GCN) based methods applied on the Function Call Graph (FCG) extracted from the APK are gaining momentum in Android malware detection,
      as GCNs are effective at learning tasks on variable-sized graphs such as FCG, and FCG sufficiently captures the structure and behaviour of an APK.
      However, the FCG lacks information about callback methods as the Android Application Programming Interface (API) is event-driven.
      This paper proposes enhancing the FCG to eFCG (enhanced-FCG) using the callback information extracted using Android Framework Space Analysis to overcome this limitation.
      Further, we add permission - API method relationships to the eFCG. The eFCG is reduced using node contraction based on the classes to get R-eFCG (Reduced eFCG) to improve the generalisation ability of the Android malware detection model.
      The eFCG and R-eFCG are then given as the inputs to the Heterogeneous GCN models to determine whether the APK file from which they are extracted is malicious or not.
      To test the effectiveness of eFCG and R-eFCG, we conducted an ablation study by removing their various components.
      To determine the optimal neighbourhood size for GCN, we experimented with a varying number of GCN layers and found that the Android malware detection model using R-eFCG with all its components with four convolution layers achieved maximum accuracy of 96.28%.
keywords:
  - Android
  - Computer security
  - Graph Convolutional Networks
  - Machine Learning
  - Program Analysis
---

# Introduction {#sec:intro}

Android is a popular smartphone Operating System that powers around 70% of the smartphones and tablets worldwide @StatCounter2021. Its popularity has long attracted a large amount of malware into its ecosystem @McAfee2020 @Securelist2020, threatening the privacy and security of its users. Three analysis techniques are prevalent to detect Android malware -- static, dynamic and hybrid analysis @Qiu2019. In static analysis, features are extracted from the Android Application Package (APK) file without executing it. The dynamic analysis executes the APK inside a sandbox and extracts run-time features. The hybrid analysis is a combination of the above. Although obfuscation techniques can hinder static analysis @Wong2018, it is substantially faster than its counterparts.

The APK file provides several features to perform static analysis. The features such as permissions and intents can be extracted from the manifest file, which are the indicators of the behaviour of the Android application (app) @Arp2014 @Kim2018 @Taheri2020 @Alazab2020. Apart from them, features such as sensitive Application Programming Interface (API) calls @Alazab2020, API call graph @Dam2017 and Function Call Graph (FCG) @Liu2018 @Wu2019 @Gao2019 can be extracted from the `Dalvik Executable (dex) code`. Out of these features, FCG captures the structure of interactions between the methods of the app. The FCG is a directed graph with methods in the `dex code` as its nodes; its edges represent Caller-Callee relationships between the methods. If every node of the FCG is assigned features that represent its behaviour, it can capture the behaviour of an app as a whole @Vinayaka2021.

The methods contained in the `dex code` can be _internal_ or _external_ depending on whether their implementation is contained in the `dex code` or not @Vinayaka2021. In general, the API methods (the _Framework Space_, $\mathcal{F}$) are external, while User-defined methods (the _Application Space_, $\mathcal{A}$) are internal. As FCGs are extracted entirely using the information present in the `dex code`, interactions from the Framework Space to the Application Space cannot be captured @Cao2015. This information is crucial as the Android API is heavily event-driven. In Android event architecture, event handlers are implemented as Application Space _callback handlers_, which are the children of Framework Space _callback methods_. The Framework Space is made aware of callback handlers using _registration methods_, which are also a part of the Framework Space @Cao2015. FCG is unable to capture the relationship between registration methods and callback handlers. The Framework Space has to be analysed to include such relationships, and its results have to be used while constructing the FCG @Cao2015 @DominguezPerez2017. 

Graph Convolutional Networks (GCNs) @Kipf2017 have become a natural choice to perform deep learning on graphs because of their flexibility @Zhang2018. GCNs process graphs by aggregating neighbourhood information, updating a node's features based on it and fine-tuning its learnable parameters for a particular task. An $n$-layer GCN aggregates features into a node from its $n$-hop neighbourhood. A global pooling operation on the graph is used to obtain the feature vector representing the graph. This vector can then be used for downstream tasks such as classification.

In this work, we analyse Framework Space code to extract Registration-Callback map motivated by the approach of @Cao2015. We also consider the mapping of permissions required by an API method from @Backes2016. This information is utilised while analysing APKs to convert FCGs extracted from them into _enhanced-FCGs_ (eFCGs). The _reduced-eFCG_ (R-eFCG) is then obtained by contracting nodes of eFCG in an approach similar to MaMaDroid's @Onwuzurike2019. Separate heterogeneous GCN models are then trained on eFCG and R-eFCG to evaluate their effectiveness.

We answer the following research questions in this paper:

1. Which components of eFCG and R-eFCGs are essential in Android malware detection using heterogeneous GCNs?
2. Can R-eFCGs achieve better generalisation in terms of Android malware detection rate than eFCGs?
3. What is the optimal neighbourhood size $n$ for GCNs to detect Android malware using eFCG and R-eFCGs?

To answer these research questions, we experiment with different components of eFCG and R-eFCGs to determine their contribution to the performance of the Android malware detection model. We also train separate models on eFCGs and R-eFCGs to access their generalisation ability. To determine the choice of optimal neighbourhood, we conducted a set of experiments by varying the number of GCN layers. As a result of these experiments, we obtained a maximum accuracy of 96.25% with R-eFCGs with all components and four GCN layers.

The key contributions of the present work are as follows:

1. We define eFCG and R-eFCG, containing the callback information and permission mappings along with the Caller-Callee information, and provide algorithms to obtain the same.
2. We conducted an ablation study to find essential components of eFCG and R-eFCG and found that all their components are essential.
3. We monitor the impact of the number of heterogeneous GCN layers on the performance of the Android malware detection model and found that its performance increases with the increasing number of layers.

   [//]: # "We integrated our Malware Detector with PGMExplainer [cite] to make it explainable and found that it provided satisfactory explanations most of the time."

The rest of this paper is organised as follows: Section @sec:motivation demonstrates a simple app and its FCG used throughout this paper. Several relevant related works are discussed in Section @sec:related-work. Section @sec:preliminaries provides an overview of mathematical concepts used in this paper. The Algorithms to obtain eFCG and R-eFCG, along with the architecture of the Android malware detection approach, are described in Section @sec:proposed-approach. The experimental framework to evaluate the current work and its results are discussed in Section @sec:experiments. Finally, the paper is concluded in Section @sec:conclusions along with discussing future directions.

# Motivation {#sec:motivation}

A simple app containing a button (class `Button`) and a text view (class `TextView`) has been used to demonstrate the FCG and its enhancements throughout this work. When the user clicks on the button, the app starts tracking their location in the background and logs it periodically to the text view. Its source code and the FCG are shown in Figure {@fig:simpleapp}.  where the registration methods `Button.setOnClickListener()` (line 45 in Figure @fig:code) and `LocationManager.requestLocationUpdates()` (line 26-31 in Figure @fig:code) are not connected to their callback handlers `onClick()` (line 20 in Figure  @fig:code) and `onLocationChangeed()` (line 7 in Figure @fig:code), respectively, in the FCG.

\begin{figure*}
\hspace{0.175\linewidth} \subfloat[
Code snippet of the demo app.\label{fig:code}
]{
\includegraphics[width=0.65\linewidth]{images/code}
}
\\

\hspace{0.2\linewidth} \subfloat[
The FCG of the code shown in \ref{fig:code}. Framework Space nodes are rectangle and Application Space nodes are oval in shape. Note that the registration methods \texttt{Button; setOnClickListener} and \texttt{LocationManager; requestLocationUpdates} are not connected to their callback handlers \texttt{MainActivity\$2; onClick} and \texttt{MainActivity\$1; onLocationChanged}, respectively. Also, their corresponding Framework Space callback methods are isolated from the rest of the nodes.
\label{fig:fcg}]{
\includegraphics[width=0.65\linewidth]{images/fcg_wide}
}
\caption{A simple app along with its FCG, showing FCG not capturing interations between callback methods and their registration methods.}
\label{fig:simpleapp}
\end{figure*}

To include relationships between registration methods and associated callback handlers, the Framework Space has to be analysed to obtain a mapping between all possible registration and callback methods. This list has to be used while analysing the APK file to identify the implementation of callback methods as callback handlers and associate them with their registration methods. This association has to be represented with a different _edge type_ in FCG, as it is different from regular caller -- callee edge type. The presence of multiple edge types makes FCG _heterogenous_. The heterogenous FCG can be further enhanced by adding relationships between the Framework Space and Permissions. FCGs can contain many nodes and edges, depending on the size of the APK @Liu2018, which potentially affects the ability of the malware detection model to generalise well, promoting the need for reducing its size @Onwuzurike2019.

# Related Work

The manifest can be used as a feature source to detect malware. For example, the permissions and intents were used to detect Android malware in @Arp2014 @Kim2018 @Taheri2020 @Alazab2020. However, permissions extracted from the manifest are not conclusive, so that they need not be used in the app despite being declared, which could lead to false positives during malware detection @Chen2020.

The `dex code` describes app behaviour. @Ren2020 represented the raw bytecode in the `dex code` in the form of a fixed-size image and provided it as the input to the Convolutional Neural Network-based Android malware detector. However, such representations completely ignore the structural information contained in the `dex code`, along with being prone to resizing losses.

The graphs extracted from `dex code` retain the structural information contained in the `dex code`. Out of these graphs, the API Call Graph captures the call order between the API methods. The API Call Graph was used as a feature source in @Dam2017, @Pektas2020. API Call Graphs are easy to work with as their maximum size is known since the number of API methods is fixed. However, they cannot capture the complete behaviour of the app as they ignore user-defined methods.

FCGs capture Caller-Callee relationships between every method of the `dex code` and are of huge magnitude @Liu2018. Therefore, they were not used as a whole in many works @Liu2018 @Wu2019 @Gao2019. Of such works, @Wu2019 use centrality measures of API methods, while @Gao2019 use graphlet frequency distribution as the feature vectors. Classifiers were trained with these feature vectors to detect Android malware. However, these works are limited because they only consider the structure of FCG, ignoring features that can be derived from method nodes.

@Liu2018 was one of the earliest works to associate node features with every node of the FCG. The feature vector was derived from the opcodes of the method, on which 1-hop neighbour XOR aggregation was performed. The aggregated feature vectors were clustered using $k$-Nearest Neighbours to obtain cluster centres. These centres were used as the graph level feature vector. This approach is similar to the working of (1-layer) GCN in terms of neighbourhood aggregation, but it ignores the presence of API nodes completely, which are essential in accessing the behaviour of an app.

GCNs were used to detect Android malware based on FCGs in @Cai2021 @Yang2021 @Vinayaka2021. Of them, @Cai2021 used a word embedding based on method name was used as a node feature of the FCG and conducted experiments on an imbalanced dataset. The node features based on the method name are inefficient in the presence of obfuscation, as it mangles the method names. Also, imbalanced datasets are known to induce biases on the performance of GCN-based classifiers @Vinayaka2021. 

API node subgraph of FCG, with centrality measures as node features, were considered in @Yang2021. This graph was the input to the GCN-based classifier. However, similar to @Dam2017 and @Pektas2020, @Yang2021 cannot completely characterise the behaviour of the APK.

GCNs considering both API nodes and User nodes were used in @Vinayaka2021. Observing the potential biases that can be induced to GCN models in terms of an imbalanced dataset and imbalanced node size distribution among the classes, @Vinayaka2021 proposed a dataset balancing algorithm. @Vinayaka2021 consider both API nodes and user nodes as a single type and ignore callback information. The present work builds on the approach of @Vinayaka2021 by treating API nodes and user nodes as different types, thus using heterogeneous FCGs. The present work also adds permission nodes to the FCG by considering API--Permission mapping and adds callback information to the FCG. This work adopts the node features of API and user nodes from @Vinayaka2021.

EdgeMiner @Cao2015 proposed a Framework Space code analysis method to extract Registration-Callback pairs and added it to the FCG to extract potentially harmful paths in it. @DominguezPerez2017 provided a more granular view of the callback methods, considering their conditions to be called back. A similar analysis was performed in @Backes2016 to extract the API method - Permission mappings. However, none of these works built an end-to-end malware detection pipeline.

# Preliminaries

This work uses several mathematical structures such as sets, functions and graphs. This section provides an overview of them along with discussing the structure of the `dex code`.

## Mathematical Collections 

A _set_ is an unordered collection of unique elements. If elements are allowed to be present in it multiple times, it is called a _multiset_. 

A _(binary) relation_ $R$ between two sets $A$ and $B$ is a subset of $A\times B$, i.e. $R\subseteq A\times B$. A _map_ (or function) $f:A\rightarrow B$ is a relation between $A$ and $B$ such that $\forall x\in A, y\in B\ \ (x,a) \in f \land (x,b) \in f \implies a=b$. A function can be thought of an association between a value $x\in A$ and a single value $y\in B$ if $(x,y)\in f$. A _multimap_ (or multifunction) is an extension to the function where several values $y\in Y$ can be associated with a single value of $x\in X$, i.e., $\forall x\in X\ \exists y \in Y\text{s.t. } (x,y) \in f$. 

The set of values (a single value, in case of maps) associated with $x\in X$ by $f$ is represented as $f(x)$. The domain of the function $f$ (represented as $\mathrm{dom}(f)$) is the set of values $x$ for which $f(x)$ is defined (in above examples, $\mathrm{dom}(f)=A$). Interested readers are referred to @Levin2021 for further information about set theory.

## Graphs

A _directed_ graph $G(V, E)$ is a collection of nodes $V$ and edges $(u,v)\in E$ where $u,v \in V$. A _multigraph_ is a graph in which $E$ is a multiset, allowing multiple edges between two nodes. A graph is _undirected_ if $(u,v) \in E \implies (v,u) \in E$. 

A path $p$ is a sequence of edges $e_1\rightarrow e_2\rightarrow \cdots \rightarrow e_n$ where every edge $e_i=(u_i,v_i)$ is distinct and $u_i=v_{i-1} \forall i>1$. Two nodes $x$ and $y$ are _connected_ in $G$ if there is a path between them. A graph is _acyclic_ if there are no paths in $G$ such that $u_1=v_n$. A _Directed Acyclic Graph (DAG)_ is a graph which is both directed and acyclic. As all these graphs consist of a single type of nodes and edges, they are _homogeneous_. Interested readers are referred to @Levin2021 for further information about graphs.

If a graph contains multiple types of nodes or edges (or both), it becomes _heterogeneous_. Heterogeneous graphs occur naturally in many fields such as Recommender Systems @Wang2019 @Ying2018 and Bioinformatics @Li2020. The concept of heterogeneous graphs is illustrated here in light of the FCG in Figure \ref{fig:fcg}, which contains nodes of Application Space $\mathcal{A}$ and Framework Space $\mathcal{F}$. Formally, a _directed heterogeneous graph_ is $G(\mathcal{V},\mathcal{E},V,E)$ where,

- $\mathcal{V}$ is the set of _node types_ (e.g, $\{\mathcal{A}, \mathcal{F}\}$),
-  $\mathcal{E}\subseteq \mathcal{V}^2$ is a multiset of _edge types_, each associated with a name (e.g, $\{\mathrm{calls}: (\mathcal{A},\mathcal{A}),\ \mathrm{calls}: (\mathcal{A},\mathcal{F})\}$,
- $V=\cup_{\tau\in \mathcal{V}}V_\tau$ is the set of the nodes and,
- $E=\cup_{t\in \mathcal{E}}E_t$ is the set of edges.

An edge set can be denoted by the name of its type followed by the nodes it connects to (e.g., $E_{\mathrm{calls}:\mathcal{A}\mapsto\mathcal{F}}$). The names of the nodes can be omitted if no other edge with the same name is present in the edge types.

A heterogeneous graph becomes undirected if $\forall t\in \mathcal{E},\ \exists t'\in \mathcal{E} \text{ s.t }\ (u,v)\in E_t \implies (v,u)\in  E_{t'}$. The structure of the heterogeneous graph is represented as a multigraph $G_M(\mathcal{V},\mathcal{E})$ called as the _metragraph_ of $G$. Figure @fig:fcg_metagraph shows the metagraph of the FCG shown in Figure @fig:fcg. Interested readers are referred to @Zhang2019 for further information about heterogeneous graphs.

If every node of the graph is associated with some attributes, the graph is called an _attributed graph._ The _attribute function_ $A_\tau:V_\tau\rightarrow \mathbb{A}_\tau$ defines the attributes for each node $v\in V_\tau$ of type $\tau$ in _attribute space_ $\mathbb{A}_\tau$. For homogeneous graphs, there is only one attribute space. 

\begin{figure}
  \centering
  \includegraphics[width=0.35\linewidth]{images/metagraph_fcg}
  \caption{The metagraph of the FCG shown in Figure \ref{fig:fcg}.}
  \label{fig:fcg_metagraph}
\end{figure}

For a graph $G$ with nodes $V$ and edges $E$, we use following notations to denote the information about neighbourhood of $v\in V$ with node type $\tau\in\mathcal{V}$ in $G$: $\{\mathrm{parents}_\tau\}_G(v) = \{u| (u,v)\in E \land u\in V_\tau\}$ is the set of $v$'s parents with type $\tau$, $\{\mathrm{children}_\tau\}_G(v) = \{w|(v,w)\in E \land\ w\in V_\tau\}$ is the set of its children with type $\tau$, $\{\mathcal{N}_\tau\}_G(v) = \{\mathrm{children}_\tau\}_G(v)$ is the set of its 1-hop neighbours with type $\tau$. If $G$ is a Homogeneous DAG, $\mathrm{pred}_G(v) = \{u| u \text{ and } v \text{ are connected in } G\}$ is the set of predecessors of $v$, $\mathrm{succ}_G(v) = \{w| v \text{ and } w \text{ are connected in } G\}$ is the set of successors of $v$. In every notation, the subscript $G$ is omitted when the graph in question can be inferred from the context and, type subscript $\tau$ is omitted if the graph is homogeneous or when we refer to nodes with all types.

## The `dex` file {#sec:dexfile}

The `classes.dex` present inside the APK contains the application logic represented as the `dex code`, to be executed by Android Runtime @Source2021. Android API is also bundled in several `dex` files, residing in `/system/framework/framework.jar` in the case of Android 11.

By parsing the `dex code`, one can obtain the sets of classes $\mathcal{C}$ and methods $\mathcal{M}$ implemented and referenced within its scope. Note that the _interfaces_ and _enums_ are treated as classes, and the _constructors_ are treated as methods in the `dex code`.  The definition of every class $c \in \mathcal{C}$ and method $m\in \mathcal{M}$ associates them with several _flags_. These flags include _modifier_ information (e.g., `public`, `static` and `abstract`) and the declaration type in the code (e.g., `interface`, `enum` and `constructor`). We define a Boolean function ${is}F(\cdot)$, which returns *true*  whenever the flag $F$ is present in the definition of its argument.

Apart from the flags, the definition of the class $c$ includes a list of its methods ($\mathrm{methods}(c)$), along with a list of its parents in the inheritance hierarchy ($\mathrm{class\_parents}(c)$). The constructors of $c$ can be obtained by filtering its methods with the flag `constructor`, i.e., $\mathrm{constructors}(c) = \{m\ |\ m\in \mathrm{methods}(c)\ \land\ \mathrm{isConstructor}(m)\}$. Similarly, the definition of method $m$ includes the types of its arguments ($\mathrm{argumentTypes}(m)$) and a reference to the class to which it belongs to ($\mathrm{class}(m)$). Multiple methods in a class can have the same name due to *method overloading*; thus, the method name along with its argument type list (the *signature*, denoted by $\mathrm{sig}(m)$) is unique for every method.

If a method $m$ is internal, the `dex code` includes its bytecode in the `dex` format. The bytecode consists of a sequence of instructions, with each instruction containing an opcode and operand(s). Each opcode is 8-bit in length, making 256 opcodes possible, of which only 230 are used @Gabor2020. As many of the opcodes do a similar task (ex., opcode range `0x90`-`0xE2` consists of binary operations such as `add`, `sub` and `mul`), they can be grouped based on their functionality. While @Liu2018 constructed 15 opcode groups, @Vinayaka2021 constructed 21 opcode groups. This work uses opcode groups of @Vinayaka2021. Interested readers are referred to the Dalvik Specification @Source2021 to get more information about the `dex code`.

Using the relationships among the methods $\mathcal{M}$ and classes $\mathcal{C}$ contained in the `dex code`, several graphs can be constructed. Out of them, the **Class-level Inheritance Graph** $\mathcal{I}^{(\mathsf{C})}(\mathcal{C}, E_\mathrm{parentOf}^{(\mathsf{C})})$, where $(c_i, c_j)\in E_\mathrm{parentOf}^{(\mathsf{C})} \iff c_i \in \mathrm{class\_parents}(c_j)$, represents the inheritance hierarchy among the classes. The **(Method-level) Inheritance Graph** $\mathcal{I}^{(\mathsf{M})}(\mathcal{M}, E_\mathrm{parentOf}^{(\mathsf{M})})$ is obtained using $\mathcal{I}^{(\mathsf{C})}$ using \eqref{eq:parentOf}.

\begin{equation}
\begin{split}
E_{\mathrm{parentOf}}^{(\mathsf{M})} = \{(m_i,m_j)\ | (&\mathrm{class}(m_i),\mathrm{class}(m_j) \in E_{\mathrm{parentOf}}^{(\mathsf{C})} \land \\ &\mathrm{sig}(m_i) = \mathrm{sig}(m_j) \}
\end{split}\label{eq:parentOf}\end{equation}

 Note that the Inheritance Graphs $\mathcal{I}^{(*)}$ are DAGs, as are should be no cyclic dependencies among classes (thus methods) in terms of inheritance. The  **Function Call Graph** $\Gamma^{(\mathsf{M})}(\mathcal{M}, E_\mathrm{calls}^{(\mathsf{M})})$, where $(m_i,m_j)\in E_\mathrm{calls}^{(\mathsf{M})}$ if $m_i$ calls $m_j$ in its code, captures the Caller-Callee relationships among the methods in the `dex code`. The superscripts $(\mathsf{M})$ and $(\mathsf{C})$ indicate that the edges are among methods and class nodes, respectively. If the superscript is not present in the graph name (e.g., $\Gamma$ and $\mathcal{I}$), they are assumed to method-level. Table \ref{tab:notations} presents a summary of the notations discussed in this section.

\input{images/notations.tex}

# Proposed Approach

The proposed Android malware detection approach consists of two analysis stages -- Framework Space Analysis and Application Space Analysis, followed by a Heterogeneous GCN based Android malware detection model. The Framework Space Analysis is done once, and its outputs are re-used in the Application Space Analysis for every app. Separate Heterogeneous GCN models are trained for eFCG and R-eFCG obtained by the Application Space Analysis. The following sections describe every stage in detail.

## Framework Space Analysis

The Framework Space Analysis analyses the Android Framework to extract a mapping between Registration and Callback methods. To do so, the `dex` file containing Framework Space code has to be parsed to get the set of Framework Classes $\mathcal{C}_{\mathcal{F}}$ and Framework Methods $\mathcal{M}_\mathcal{F}$. From $\mathcal{C}_{\mathcal{F}}$ and $\mathcal{M}_\mathcal{F}$, the Framework Space Inheritance Graph $\mathcal{I}_\mathcal{F}$ and Framework Space FCG $\Gamma_\mathcal{F}$ are obtained, respectively. The approach of @Cao2015 is adopted to extract potential callback methods from the Framework Space code, which are then filtered to obtain final callback methods along with corresponding registration methods. The architecture of Framework Space Analysis is shown in Figure @fig:framework_analysis.

![The workflow of Framework Space Analysis](images/framework_analysis.pdf){#fig:framework_analysis fullwidth=1 width=0.8}

### Potential Callback Filter {#sec:potentialFilter}

A potential callback method is a Framework Space method which is visible to the Application Space and can be overridden by it. For a method $m$ with $c=\mathrm{class}(m)$, if all of the following criterion are satisfied, then it becomes a potential callback method @Cao2015:

1. $\mathrm{isPublic}(c) = 1$
2. $\mathrm{isFinal}(c) = 0$
3. $\mathrm{isInterface}(c) = 1\ \lor\ \lor_{x\in \mathrm{constructors}(c)}\mathrm{isPublic}(x)$
4. $\mathrm{isPublic}(m) = 1 \lor \mathrm{isProtected}(m) = 1$

Criterion 1, 2 and 3 ensure that the class $c$ is visible to Application Space classes and can be extended; Criteria 4 ensures that the method $m$ can be overridden in Application Space. As all interface methods are public by default, Criteria 4 is true for them. $P$ denotes the set of all potential callbacks.

### Registration-Callback Map Extraction {#rcPairs}

A method $m$ being potential callback does not guarantee that its Application Space override $m'$ can be *introduced* back to the Framework Space through an Application Space visible registration method $r$ and, subsequently called back by the Framework Space. Note that to *introduce* $m'$ to $r$, the method $r$ must take an argument of type $c = \mathrm{class}(m)$, thus, accepting any instance of class $c'$ derived from $c$, overriding $m$ in its method $m'$. 

To filter out the methods $m$ whose overrides cannot be introduced to Framework Space, we use _Argument Map_. The **Argument Map** is a multimap $\alpha_\mathcal{F}:\mathcal{C}_\mathcal{F}\rightarrow \mathcal{M}_\mathcal{F}$, where $(c,m) \in \alpha_\mathcal{F} \iff c\in \mathrm{argumentTypes}(m)$. In other words, for a Framework Space class $c$, $\alpha_\mathcal{F}(c)$ is a set of methods $M\subset \mathcal{M}_\mathcal{F}$, in which $c$ is an argument of. If $\alpha_\mathcal{F}(c)=\varnothing$ for $c=\mathrm{class}(m)$, then the class $c$ cannot be passed back to the Framework Space, therefore all of its methods are not callback methods.

A registration method $r$ taking an argument of type $c$ need not necessarily invoke the method $m$ of $c$. To check for the invocation of $m$, a complete _reverse data-flow analysis_ tracking $c$ until the invocation of $m$ is required as in @Cao2015. However, we empirically observe that the invocation of $m$ happens in a method $\mu$ either belonging to $u=\mathrm{class}(r)$ or some nested class $u'$ of $u$ most of the times. Therefore, the criterion to consider the method $m$ with $c=\mathrm{class}(m)$ as a final callback method are defined as follows:

1. $c$ is an argument of some Application Space visible method $r$. i.e., $\exists\ r\in \alpha_\mathcal{F}(c)\ \text{ s.t. } \mathrm{isPublic}(r) \land \mathrm{isPublic}(\mathrm{class}(r))$, and,
2. Some method $\mu$ either belonging to $u=\mathrm{class}(r)$ or some nested class $u'$ of $u$ invokes $m$ in its code.

If a method $m$ satisfies above criterion, then the method $r$ is the *registration method* of $m$ and, the pair $(r,m)$ is added to the Registration-Callback map $\mathcal{R}$. The process of extracting the Registration-Callback map is summarized in Algorithm 1.

\begin{algorithm}
\footnotesize
\begin{algorithmic}[1]
\Procedure{AnalyseFramework}{$\mathcal{C}_\mathcal{F}, \mathcal{M}_\mathcal{F}$}
\LineCommentCont{Extract the Registration-Callback map $\mathcal{R}$ using $\mathcal{C}_\mathcal{F}$ -- Set of Framework Space Classes and $\mathcal{M}_\mathcal{F}$ -- Set of Framework Space Methods.}
\State{$\mathcal{I}_\mathcal{F}\gets$ Extract Inheritance Graph using $\mathcal{C}_\mathcal{F}$} \Comment{See Section \ref{sec:dexfile}}
\State{$\Gamma_\mathcal{F}\gets$ Extract FCG using $\mathcal{M}_\mathcal{F}$}\Comment{See Section \ref{sec:dexfile}}
\State{$\alpha_\mathcal{F}\gets$ Extract Argument Graph using $\mathcal{M}_\mathcal{F}$ and $\mathcal{C}_\mathcal{F}$}\Comment{See Section \ref{rcPairs}}
\State{$P \gets$ Extract Set of Potential Callbacks from $\mathcal{M}_\mathcal{F}$}\Comment{See Section \ref{sec:potentialFilter}}
\State{$C_P\gets \varnothing$}\Comment{Multimap of methods in $P$ keyed by their class}
\For{$m$ in $P$}
\If{$\exists u\text{ s.t. } (\mathrm{class}(m), u)\in \alpha_\mathcal{F}$}\LineCommentCont{check if $\mathrm{class}(m)$ is used anywhere}
\State{$C_P\gets C_P\cup (\mathrm{class}(m), m)$}
\EndIf
\EndFor
\State{$\mathcal{R}\gets\varnothing$}\Comment{Registration Callback Pairs}
\For {$c$ in $\mathrm{dom}(C_P)$}
\State{$R\gets \{(\mathrm{class}(r), r)\ |\ r \in \alpha_\mathcal{F}(c) \land \mathrm{isPublic}(r) \land \mathrm{isPublic}(\mathrm{class}(r))\}$} \Comment{Multimap of possible registration methods for class $c$ keyed by their classes}
\For{$p$ in $C_P(c)$}\Comment{Loop through Potential Callback methods $p$ of class $c$}
\State{$U\leftarrow \{\mathrm{class}(u)\ |\ u\in \mathrm{parents}_{\Gamma_\mathcal{F}}(p) \}$}\LineCommentCont{Set of classes that have at least one method calling $p$}
\State{$\mathcal{R} \gets \mathcal{R} \cup \{(r,p)\ |\ c\in (U\cap\mathrm{dom}(R))\ \land\ r\in R(c)\}$} \LineCommentCont{Update Registration-Callback map considering the classes that call $p$ and have registration method containing $c$ in their argument. Note that the $\cap$ operation is \textit{approximate} (see Section \ref{rcPairs}).}
\EndFor
\EndFor
\State{\textbf{return} $\mathcal{R}$, $\mathcal{I}_\mathcal{F}$}
\EndProcedure
\end{algorithmic}
\caption{ Framework Space Analysis}
\end{algorithm}


Note that whenever $r$ is a registration method, any Framework Space child $r'$ of $r$ can be a registration method too, assuming that $r'$ invokes $r$ with its parameters. Therefore, $(r, p)\in \mathcal{R} \implies (r',p)\in \mathcal{R}$. As adding $(r',p)$ to the Registration-Callback map $\mathcal{R}$ increases the size of $\mathcal{R}$ significantly,  Framework Space Inheritance Graph $\mathcal{I}_\mathcal{F}$ is provided to Application Space Analysis to infer such relationships.

## Application Space Analysis {#sec:app_analysis}

Application Space Analysis extracts the `dex` file from the APK and parses it to get the set of Application Space classes and methods $\mathcal{C}_\mathcal{A}$ and $\mathcal{M}_\mathcal{A}$, respectively. Note that the $\mathcal{C}_\mathcal{A}$ (and $\mathcal{M}_\mathcal{A}$) includes the classes (and methods) implemented in Application Space $C_\mathcal{A}$ ($M_\mathcal{A}$), along with the reference to classes (methods) from Framework Space $C_\mathcal{F} \subset \mathcal{C}_\mathcal{F}$ ($M_\mathcal{F} \subset \mathcal{M}_\mathcal{F}$). Therefore, $\mathcal{C}_\mathcal{A}=C_\mathcal{A}\cup C_\mathcal{F}$ and $\mathcal{M}_\mathcal{A}=M_\mathcal{A}\cup M_\mathcal{F}$. The $\mathcal{M}_\mathcal{A}$ and $\mathcal{C}_\mathcal{A}$ are used to derive Application Space FCG $\Gamma_\mathcal{A}\left(\mathcal{M}_\mathcal{A}, E_{\mathrm{calls}}^{(\mathsf{M})}\ \right)$ and Application Space Method level Inheritance Graph $\mathcal{I}_\mathcal{A}\left(\mathcal{C}_\mathcal{A}, E_{\mathrm{parentOf}}^{(\mathsf{M})}\right)$, respectively. As the the methods in $M_\mathcal{F}$ are only references, their inheritance information is not contained in $\mathcal{I}_\mathcal{A}$. The edges $E_{\mathrm{calls}}^{(\mathsf{M})}$ of the FCG $\Gamma_\mathcal{A}$ can be partitioned into $E_{\mathrm{calls}:\mathcal{A}\mapsto\mathcal{A}}^{(\mathsf{M})}$ and $E_{\mathrm{calls}:\mathcal{A}\mapsto\mathcal{F}}^{(\mathsf{M})}$ to represent Caller-Callee relationships between methods in different spaces.

![Stages in Application Space Analysis](images/application_analysis.pdf){#fig:app_analysis width=0.7}

The Application Space Analysis proceeds through several stages as outlined in Figure @fig:app_analysis, each enriching the FCG, converting it to eFCG $\Gamma_e$ at the end. The eFCG is a heterogeneous graph $\Gamma_e(\mathcal{V}, \mathcal{E},V^{(\mathsf{M})}, E^{(\mathsf{M})})$ where, 

- $\mathcal{V}=\{\mathcal{A}, \mathcal{F}, \mathcal{P}\}$ is the set of node types,
- $\mathcal{E}=\{\mathrm{calls}:(\mathcal{A}, \mathcal{A}), \mathrm{calls}:(\mathcal{A}, \mathcal{F}), \mathrm{parentOf}:(\mathcal{A}, \mathcal{A}), \mathrm{parentOf}:(\mathcal{F}, \mathcal{A}), \mathrm{callsBack}: (\mathcal{F}, \mathcal{F}), \mathrm{requires}:(\mathcal{F}, \mathcal{P}) \}$ is the set of edge types,
- $V_\mathcal{F}^{(\mathsf{M})}=M_\mathcal{F}$, $V_\mathcal{A}^{(\mathsf{M})}=M_\mathcal{A}$, and $V_{\mathcal{P}}^{(\mathsf{M})}=P$ are the sets of nodes, and
- $E_{\mathrm{calls}:\mathcal{A}\mapsto\mathcal{A}}^{(\mathsf{M})}$, $E_{\mathrm{calls}:\mathcal{A}\mapsto\mathcal{F}}^{(\mathsf{M})}$, $E_{\mathrm{parentOf}:\mathcal{A}\mapsto\mathcal{A}}^{(\mathsf{M})}$, $E_{\mathrm{parentOf}:\mathcal{F}\mapsto\mathcal{A}}^{(\mathsf{M})}$, $E_\mathrm{callsBack}$ and $E_\mathrm{requires}$ are the sets of edges.

The metagraph $\{\Gamma_e\}_M$ of the eFCG is shown in Figure @fig:metagraph. The Application Space Analysis further reduces eFCG into R-eFCG $\Gamma_e^{(\mathsf{C})}$ using eFCG reducer. These stages of the Application Space Analysis and the nodes and edges they add to the FCG are described in detail in the following paragraphs.

![Metagraph $\{\Gamma_e^{(*)}\}_M$ of eFCG and R-eFCG](images/metagraph.pdf){#fig:metagraph width=0.7}

### Inheritance Edges Adder

The event handlers are implemented in the Application Space as an overridden method of a Framework Space callback method. The FCG cannot capture this information as the event handler does not call its parent callback method most of the time.

To add the relationship between event handler and its parent callback method to the FCG, the inheritance hierarchy has to be considered. By adding the edges in $E_{\mathrm{parentOf}}^{(\mathsf{M})}$ contained in Method level Inheritance Graph $\mathcal{I}_\mathcal{A}$, the event handlers are connected to their parent callback methods, along with connecting Application Space methods to their parents. Thin dashed edges in Figure @fig:efcg represent the edges in $E_{\mathrm{parentOf}}^{(\mathsf{M})}$. As the inheritance may be among Application Space nodes $\mathcal{A}$, or from the Framework Space nodes $\mathcal{F}$ to the Application Space nodes $\mathcal{A}$, the inheritance edge set $E_{\mathrm{parentOf}}^{(\mathsf{M})}$ can be partitioned into $E_{\mathrm{parentOf}:\mathcal{A}\mapsto\mathcal{A}}^{(\mathsf{M})}$ and $E_{\mathrm{parentOf}:\mathcal{F}\mapsto\mathcal{A}}^{(\mathsf{M})}$ to represent these cases, respectively.

### Callback Edges Adder

The registration methods and the callback methods are not related in the FCG, as their Caller-Callee relationship cannot be inferred without the help of the results of Framework Space Analysis.

The Registration Callback map $\mathcal{R}$ can be used to add edges between the registration methods and the corresponding callback methods. As the Framework Space inheritance information is not contained in $\mathcal{I}_\mathcal{A}$ (thus in $E_{\mathrm{parentOf}}^{(\mathsf{M})}$), $\mathcal{I}_\mathcal{F}$ has to be considered while adding callback edges.

For every Framework Space method $m$ in $M_\mathcal{F}$, with the help of $\mathcal{R}$ and $\mathcal{I}_\mathcal{F}$, it is determined whether $m$ is a registration method. If so, the corresponding callback methods $P$ are obtained. The edges between $m$ and the callback method $p\in P$ is added if $p\in M_\mathcal{F}$. The process of obtaining callback edges $E_{\mathrm{callsBack}}^{(\mathsf{M})}$ is detailed in Algorithm \ref{algo:cb-edges}. Bold dashed edges in Figure @fig:efcg represent the edges in $E_{\mathrm{callsBack}}^{(\mathsf{M})}$. Note that the edges in $E_{\mathrm{callsBack}}^{(\mathsf{M})}$ are always among Framework Space methods $\mathcal{F}$.

\begin{algorithm}
\footnotesize
\begin{algorithmic}[1]
\Procedure{GetCallbackEdges}{$\Gamma_\mathcal{A}, \mathcal{I}_\mathcal{F},
\mathcal{R}$}
\LineCommentCont{Get a list of callback edges $E_{\mathrm{callsBack}}^{(\mathsf{M})}$ using Application Space FCG $\Gamma_\mathcal{A}$, Framework Space Method level Inheritance Graph $\mathcal{I}_\mathcal{F}$, and Registration Callback map $\mathcal{R}$.}
\State{$E_{\mathrm{callsBack}}^{(\mathsf{M})}\gets \varnothing$}
\For{$m$ \textbf{in} $M_\mathcal{F}$}
	\For{$p$ \textbf{in} $\{m\}\cup\mathrm{pred}_{\mathcal{I}_\mathcal{F}}(m)$}
    	\If{$p\in \mathrm{dom}(\mathcal{R})$}
\State{$E_{\mathrm{callsBack}}^{(\mathsf{M})}\gets E_{\mathrm{callsBack}}^{(\mathsf{M})} \cup \{ (m,c) \ |\ c\in\mathcal{R}(p)\land c\in M_\mathcal{F} \}$}
		\EndIf
	\EndFor
\EndFor
\State{\textbf{return} $E_{\mathrm{callsBack}}^{(\mathsf{M})}$}
\EndProcedure
\end{algorithmic}
\caption{Callback Edge Addition} \label{algo:cb-edges}
\end{algorithm}

### Permission Nodes Adder

The manifest file contains a list of permissions that are required by an app to run. As it is possible to request permission and not use it @Chen2020, permissions required by used Framework Space methods can be used to get a list of actual permissions needed. Axtool @Backes2016 provides a mapping $\Psi:\mathcal{M}_\mathcal{F}\rightarrow\mathcal{P}$ between the Framework Space methods $\mathcal{M}_\mathcal{F}$ and Permission Space $\mathcal{P}$. For a Framework method $m\in M_\mathcal{F}$, $\Psi(m)$ is the set of permissions that is required by $m$. 

The permission nodes $P$ and the edges $E_{\mathrm{requires}}^{(\mathsf{M})}$ to be added to the FCG are calculated using \eqref{eq:perm_nodes} and \eqref{eq:perm_edges}, respectively.
$$
P=\bigcup_{m\in M_{\mathcal{F}}} \Psi(m)
$$ {#eq:perm_nodes}

$$
E_\mathrm{requires}^{(\mathsf{M})} = \{(m,p)\ | \ m\in M_{\mathcal{F}} \land p\in \Psi(m)\}.
$$ {#eq:perm_edges}

Underlined nodes in Figure @fig:efcg represent the permission nodes $P$ and bold solid edges represent the edges in $E_{\mathrm{requires}}^{(\mathsf{M})}$. Note that the edges in $E_{\mathrm{requires}}^{(\mathsf{M})}$ are always from the Framework Space nodes $\mathcal{F}$ to the Permission nodes $\mathcal{P}$.

### Node Attributes Assigner 

After adding inheritance edges, callback edges and permission nodes and edges, the FCG becomes heterogeneous. The nodes of it consist of Application Space methods $M_\mathcal{A}$, Framework Space methods $M_\mathcal{F}$, and Permissions $P$. For every node, the attributes are assigned using attribute scheme $A$ as follows:

- For Framework Space nodes $m$, $A_\mathcal{F}(m)$ is a one-hot vector describing the position of the API package to which $m$ belongs in the API packages list obtained from @AndroidDevelopers2021. 
- For Application Space nodes $m$, $A_\mathcal{A}(m)$ is a 21-bit Boolean vector representing the opcode groups that are used in its body as in @Vinayaka2021.
- For Permission nodes $p$, $A_\mathcal{P}(p)$ is a concatenation of one-hot vector of the group that it belongs to, and a bit indicating whether it is dangerous or not @AndroidSource2021.

Note that the package list in @AndroidDevelopers2021 is in alphabetical order. This alphabetical order is not mandatory as long as the same package indices are used during training and testing. The attributes are assigned as a vector $\mathbf{h}_i^{(0)}$ for every node $i$.

### eFCG Reduction

As the eFCG $\Gamma_e$ contains large number of nodes and edges, the ability of the Android malware detection model to generalise might be limited @Onwuzurike2019. To overcome this problem, the method nodes ($\mathcal{F}$ and $\mathcal{A}$) are contracted based on their classes as in MaMaDroid @Onwuzurike2019 to get Reduced-eFCG (R-eFCG). Formally, the R-eFCG is $\Gamma_e^{(\mathsf{C})}(\mathcal{V},\mathcal{E}, V^{(\mathsf{C})}, E^{(\mathsf{C})})$ where,

- $\mathcal{V}$ and $\mathcal{E}$ carry the same meaning as in eFCG (See Section @sec:app_analysis).
- The set of nodes of R-eFCG is obtained by contracting the methods to their classes for $\tau=\mathcal{A}$ and $\tau=\mathcal{F}$, and keeping the permission nodes intact. i.e., $V_\tau^{(\mathsf{C})}=\{ \mathrm{class}(m)\ |\ m\in V_\tau^{(\mathsf{M})}  \}$ for $\tau\not=\mathcal{P}$ and $V_\mathcal{P}^{(\mathsf{C})}=V_\mathcal{P}^{(\mathsf{M})}=P$.
- The set of edges of R-eFCG is obtained by mapping the edges between the methods to their respective classes. The edge set $E_{\mathrm{requires}:\mathcal{F}\mapsto\mathcal{P}}^{(\mathsf{C})}$ of the R-eFCG is obtained by mapping the source nodes $m\in V_\mathcal{F}^{(\mathsf{M})}$  in $E_{\mathrm{requires}:\mathcal{F}\mapsto\mathcal{P}}^{(\mathsf{M})}$ to their respective classes. i.e.,  $E_t^{(\mathsf{C})}=\{(\mathrm{class}(m_i), \mathrm{class}(m_j))\ |\ (m_i,m_j)\in E_t^{(\mathsf{M})}\}$ for $t\not=\mathrm{requires}$, $E_{\mathrm{requires}}^{(\mathsf{C})}=\{(\mathrm{class}(m),p)\ |\ (m,p)\in E_\mathrm{requires}^{(\mathsf{M})}\}$.

The attributes of the class nodes are derived by *binary-OR*ing the node attributes of their member methods. The eFCG and R-eFCG of the simple app shown in Figure @fig:code is illustrated in Figure @fig:eFCG. Observe that the registration methods and callback handlers are connected through callback methods in the eFCG.

\begin{figure*} \subfloat[eFCG \label{fig:efcg}]{\includegraphics[width=0.6\linewidth]{images/efcg/efcg}} \hfill \subfloat[R-eFCG \label{fig:refcg}]{\includegraphics[width=0.4\linewidth]{images/efcg/refcg}} \caption{eFCG and R-eFCG of the simple app shown in Figure \ref{fig:code}. The nodes in $\mathcal{A}$ are oval,  the nodes in $\mathcal{F}$ are rectangle in shape. The nodes in $\mathcal{P}$ are underlined. Caller-Callee relationships between the nodes are represented in thin soild edges, callback relationships in bold dashed edges, inheritance relationships in thin dashed edges, and, permission relationships are represeted in bold edges. \label{fig:eFCG}}\end{figure*}

## GCN Classifier

The GCN classifier consists of several Heterogeneous GCN layers, each containing a GCN module for every edge type. The eFCG and R-eFCGs are converted into undirected graphs before providing them as the inputs to the GCN classifier by adding a reverse edge type for every edge type present in the graph to ensure that data flow happens between every node type.

Every GCN module is implemented using `GraphConv` algorithm @Kipf2017. At every layer $l$, the hidden representation $\mathbf{h}_i^{(l+1)}$ of node $i$ with type $s\in \mathcal{V}$ is first calculated using GCN module of edge $e$ where $e=(s,\tau),\ e\in \mathcal{E}$ using following operations:
$$
\{\mathbf{h}_{i}^{(l+1)}\}_e = \sigma\left( \mathbf{b}^{(l)} + \sum_{j\in \mathcal{N}_\tau(i)}\frac{1}{c_{ij}}\mathbf{h}_{j}^{(l)}\mathbf{W}^{(l)}\right)
$$ {#eq:edge_conv}

$$
\mathbf{h}_i^{(l+1)} = \sum_{e\in \mathcal{E}}\{\mathbf{h}_i^{(l+1)}\}_e
$$ {#eq:agg}

where,
$$
c_{ij}=\frac{1}{\sqrt{|\mathcal{N}_\tau(i)|\times |\mathcal{N}_s(j)|}}
$$ {#eq:coeff}
is the normalisation coefficient between node $i$ and node $j$, $\sigma$ is an activation function ($\mathrm{ReLu}$ in this work), $\mathbf{W}^{(l)}$ and $\mathbf{b}^{(l)}$ are the weight and bias matrices at layer $l$, respectively. The edge type-wise GCN operation is represented in \eqref{eq:edge_conv}, which are aggregated in \eqref{eq:agg}. The normalisation coefficient is calculated in \eqref{eq:coeff} to limit the magnitude of the aggregated features. After $n$ convolution layers, the node features of node type $\tau$ are aggregated using a *readout* operation as in \eqref{eq:node_readout} (*mean* in this work) to get $\mathbf{h}_\tau$. The readout features for all node types $\tau\in\mathcal{V}$ are then concatenated (operator $||$) in \eqref{eq:concat} to get a graph-level embedding vector $\mathbf{h}$.
$$
\mathbf{h}_\tau=\frac{1}{|V_\tau|}\sum_{\ i\in V_\tau}\mathbf{h}_i^{(n)}
$$ {#eq:node_readout}
$$
\mathbf{h} = \underset{\tau\in\mathcal{V}}{\large\|}\mathbf{h}_t.
$$ {#eq:concat}
The graph embedding $\mathbf{h}$ can be passed to any downstream task. This work uses a 1-layer fully connected neural network followed by the sigmoid activation function as the classifier. Thus, the probability of a given eFCG (or R-eFCG) is from malware APK can be given using \eqref{eq:linear},
$$
P\left(\mathrm{Malware}|\Gamma_e^{(*)}\right)=\mathrm{sigmoid}(b+\mathbf{h}\mathbf{W}).
$$ {#eq:linear}
where $\mathbf{W}$ and $b$ are the weight matrix and bias of the classifier, respectively. For classification purposes, if $P>0.5$, the sample is regarded as malware, otherwise benign.

# Experiments, Results and Analysis {#sec:experiments}

The experiments to answer the research questions posed in section @sec:intro are described in this section, along with the configurations.

## Software Configuration

APK processing and heterogeneous graph extraction were performed using Androguard @ADT2021. Heterogeneous graph extraction was parallelised using JobLib @JDT2021. GCNs were implemented and trained using Deep Graph Library @Wang2019a on top of PyTorch @Paszke2019 and PyTorch-Lightning @Falcon2019, with runs tracked using Weights & Biases @Biewald2020.

## Datasets used

Maldroid2020 @Mahdavifar2020 and AndroZoo @Allix2016 datasets were used to build the model. The dataset balancing approach of @Vinayaka2021 was applied on Maldroid2020, with adding additional APKs from AndroZoo. The final dataset was balanced both in terms of the number of APKs and node count distribution and contained a total of 11760 APKs. The dataset was divided into training, validation, and testing splits with a ratio of 60%, 20% and 20%, respectively, while ensuring that the node count distribution of all splits remained the same. 

## Training Configuration 

Every GCN model was trained using the Binary Cross-Entropy loss function, as the model was learning a probability distribution. Adam Optimiser @Kingma2015 was used to optimise the parameters of the model as it performs better than other optimisers, even in its default configuration (learning rate=$10^{-3}$). The maximum number of epochs was set to 100, and the model at epoch $e$ having minimum validation loss was chosen for testing.

## Experiments

### Ablation Study

To determine the essential node types of eFCG and R-eFCG, ablation study was conducted by restricting the node types $\mathcal{V}$ to -- $\mathrm{code} = \{\mathcal{A}\}$, $\mathrm{core}=\{\mathcal{A}, \mathcal{F}\}$ and $\mathrm{all}=\mathcal{V}\overset{\mathrm{def}}{=}\{\mathcal{A},\mathcal{F},\mathcal{P}\}$. The GCN models are trained and tested using this reduced set of node types. Note that the Application Space nodes $\mathcal{A}$ are present in all sets as they contain crucial logic that can be used as a behaviour indicator of an app. Thus, the ablation study aims to test whether Framework and Permission nodes improve the performance of the model significantly.  

### Neighbourhood Analysis

Every node configuration was trained with a variable number of Heterogeneous GCN layers starting from $n=0$ to test whether an increasing number of GCN layers (thus, a larger neighbourhood) improves the Android malware detection model performance. The case of $n=0$ represents the set of baseline Android malware detection models in which aggregated and concatenated node attributes are directly passed as the input to the sigmoid classification model. 

### Generalisation Analysis

Every configuration in the ablation study and neighbourhood analysis was conducted for eFCG and R-eFCG by training separate GCNs. These experiments were used to determine whether R-eFCG performs better than eFCG, implying its ability to generalise.

## Experimental Results and Analysis

Summary of obtained experimental results is shown in Table \ref{tab:res}. From it, several insights about research questions can be drawn, which are discussed in the following sections:

\input{images/table}

### Effectiveness of Node types

With Application Space nodes $\mathcal{A}$ only, the model was able to achieve a mean accuracy of 84.63% with a standard deviation of 7.79%. With the addition of framework space nodes $\mathcal{F}$, the mean accuracy was increased by 6.86%, reaching 91.49% with a standard deviation of 4.29%. The addition of permission nodes slightly improved the mean accuracy by 1.58%, making the model achieve a mean accuracy of 93.07% with a standard deviation of 4.02%. The trend of increasing accuracy with the addition of node types is shown in Figure @fig:acc_nodetype. These results emphasise that the Framework Space nodes are crucial to detect Android malware. Similarly, the contribution of permission nodes to the performance of the model is essential, although they are less in number.

![Mean and Standard Deviation of Accuracy of the model for different node type configurations.](images/acc_nodetype.pdf){#fig:acc_nodetype width=0.7}

### Effect of neighbourhood size $n$

With $n=0$, the baseline models performed better than a random-guess model obtaining a mean accuracy of 80.35% with a standard deviation of 7.60%, suggesting that the node attributes play an essential role to detect Android malware. Subsequent addition of GCN layers improved the mean accuracy by 9.29%, 2.49%, 0% and, 1.27%, respectively. No performance improvements were observed during the addition of the third GCN layer for "$\mathrm{core}$" and "$\mathrm{all}$" configurations. The addition of the fourth GCN layer did not improve the accuracy by a significant amount. The variation of accuracy with the addition of GCN layers shown in Figure @fig:acc_n suggests that $n=2$ is a sweet spot between accuracy and inference time, as the number of GCN layers directly affect the inference time.

![Mean Accuracy of the model containing $n$ GCN layers. Shaded area represents the standard deviation of accuracy.](images/acc_n.pdf){#fig:acc_n width=0.7}

### Generalisation ability of R-eFCG

R-eFCGs performed better then eFCGs all node configurations as evident from Table \ref{tab:res}. A statistical analysis of the accuracies obtained with eFCGs and R-eFCGs suggest that the R-eFCGs improve the mean accuracy by 2.35% with a standard deviation of 1.25%. Minimum improvements less than 1% were observed with $n=4$ and node configuration "$\mathrm{code}$" and "$\mathrm{all}$" along with $n=2$ with node configuration "$\mathrm{all}$".

These results suggest that R-eFCGs can generalise better than eFCGs in most cases. In the _sweet spot_ $n=2$ with node configuration $\mathrm{all}$, R-eFCGs can be used as a replacement to eFCGs, thus making inference faster, as they have fewer nodes than eFCGs. Note that R-eFCG $\Gamma_e^{(\mathsf{C})}$ has to be calculated after $\Gamma_e$ (see Section @sec:app_analysis), thus adding additional computational step. However, the procedure of section @sec:app_analysis can be easily tuned to output R-eFCGs instead of eFCGs by considering classes instead of methods and using their attribute schemes.

### Comparison with Related Works {.unnumbered}

The "$\mathrm{core}$" configuration of this work using eFCGs is conceptually similar to FCGs used in @Vinayaka2021. While @Vinayaka2021 reported accuracy of 92.29% with 3 GCN layers, the "$\mathrm{core}$" configuration using eFCGs with $n=3$ achieved a similar accuracy of 92.08%. The proposed method could not be compared with @Cai2021 @Yang2021 as they did not incorporate any node-count distribution balancing strategies and did not disclose their dataset.

# Conclusions and Future Work {#conclusions}

This paper proposed an Android malware detection approach based on the heterogenous Caller-Callee graphs extracted from the APK files. First, the heterogeneous graphs eFCG and R-eFCG were defined, and algorithm to obtain the same were discussed. These graphs incorporate the information about callback and permissions obtained by the Framework Space Analysis. Then, separate heterogeneous graph models were trained on them to evaluate their performance. Finally, the experiments to determine optimal neighbourhood and essential components of heterogeneous graphs were also conducted. As a result of these experiments, a maximum accuracy of 96.28% was obtained.

There is further scope to improve this work in multiple directions. During Framework Space Analysis, the algorithm to find Registration-Callback map can be made more exact, and the difference of their results with our approximate method can be compared and contrasted. In Application Space Analysis, the nodes can be assigned more informative features, such as package name-based embedding for Framework Space nodes and opcode sequence embedding for Application Space Nodes. Finally, explainability methods can be integrated with the GCN models to identify and understand critical nodes that contain malicious code.
