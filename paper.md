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
    photo: a3.png

  - key: 2
    name: Jaidhar C D
    institution: National Institute Technology Karnataka, Surathkal
    city: Srinivasanagar
    address: Mangaluru, Karnataka, India - 575025
    email: jaidharcd@nitk.edu.in
    photo: a2.png

correspondingAuthor:
  name: Vinayaka K V
  email: vinayakakv.193it001@nitk.edu.in

abstract: |
      The popularity of the Android Operating System in the smartphone market has attracted lots of malware into its ecosystem.
      To accurately detect these malware, many of the existing works use machine learning and deep learning-based methods,
      in which feature extraction methods were used to extract fixed-size numerical feature vectors using the files present inside the Android Application Package (APK).
      Recently, Graph Convolutional Network (GCN) based methods applied on the Function Call Graph (FCG) extracted from the APK are gaining momentum in Android Malware detection,
      as GCNs are effective at learning tasks on variable sized graphs such as FCG, and FCG sufficiently captures the structure and behaviour of an APK.
      However, the FCG lacks the information about callback methods as the Android Application Programming Interface (API) is event-driven.
      To overcome this limitation, we propose enhancing the FCG to eFCG (enhanced-FCG) using the callback information extracted using Android Framework space analysis.
      Further, we add permission - API method relationships to eFCG. To improve the generalisation ability of the model, the eFCG is reduced using node contraction based on the classes to get R-eFCG (Reduced eFCG).
      The eFCG and R-eFCG are then given as the inputs to the Heterogeneous GCN models to get the prediction of malicious behaviour of the APK.
      To test the effectiveness of eFCG and R-eFCG, we conducted an ablation study by removing various components of them.
      To determine the optimal neighbourhood size for GCN, we experimented with a varying number of GCN layers and found that the model using R-eFCG with all components of it with four convolution layers achieved a maximum accuracy of 96.28%.
keywords:
  - Android Malware
  - Graph Convolutional Networks
  - Program Analysis
---

# Introduction {#sec:intro}

Android is a popular smartphone Operating System (OS) that powers around 70% of the smartphones and tablets worldwide @StatCounter2021. Its popularity has long attracted enormous malware into its ecosystem @McAfee2020 @Securelist2020, threatening the privacy and security of its users. To detect Android malware, three analysis techniques are prevalent -- static, dynamic and hybrid analysis @Qiu2019. In static analysis, features are extracted from the Android Application Package (APK) file without executing it. The dynamic analysis executes the APK inside a sandbox and extracts features. Hybrid analysis is a combination of above both. Although static analysis can be hindered by obfuscation @Wong2018, it is substantially faster than its counterparts.

The APK file provides several features to perform static analysis. The features such as permissions and intents can be extracted from manifest file, which are the indicators of the behaviour of the application (app) @Arp2014 @Kim2018 @Taheri2020 @Alazab2020. Apart from them, features such as sensitive Application Programming Interface (API) calls @Alazab2020, API call graph @Dam2017 and Function Call Graph (FCG) @Liu2018 @Wu2019 @Gao2019 can be extracted from the Dalvik Executable (dex) code. Out of these features, FCG captures the structure of interactions between the methods of the app. The FCG is a directed graph with methods contained in the dex code as its nodes; its edges represent caller-callee relationships between the methods. If every node of the FCG is assigned features that are representative of its behaviour, it can capture the behaviour of an app as a whole @Vinayaka2021.

The methods contained in the dex code can be _internal_ or _external_ depending on whether their implementation is contained in the dex code or not @Vinayaka2021. In general, the API methods (the _Framework Space_) are external, while User-defined methods (the _Application Space_) are internal. As FCGs are extracted entirely using the information present in the dex code, interactions between the Framework Space and Application Space can not be captured @Cao2015. This information is crucial as the Android API is heavily event-driven. In Android event architecture, event handlers are implemented as Application Space _callback handlers_, which are the children of Framework Space _callback methods_. The Framework Space is made aware of callback handlers using _registration methods_, which are also a part of the Framework Space @Cao2015. FCG is unable to capture the relationship between registration methods and callback handlers, as seen in Figure {@fig:simpleapp}, where the registration methods `Button.setOnclickListener()` (line 45 in Figure @fig:code, node 17 in Figure @fig:fcg) and `LocationManager.requestLocationUpdates()` (line 26-31 in Figure @fig:code, node 13 in Figure @fig:fcg) are not connected to their callback handlers `onClick()` (line 20 in Figure  @fig:code, node 22 in Figure @fig:fcg) and `onLocationChangeed()` (line 7 in Figure @fig:code, node 20 in Figure @fig:fcg), respectively, in FCG.

\begin{figure*}
\subfloat[
Code snippet of an app that starts monitoring user location on \texttt{Button} click, and writing the monitored location to a \texttt{TextArea}. The methods \texttt{onClick} (line 20) and \texttt{onLocationChanged} (line 7) are callback handlers; \texttt{Button.setOnClickListener} (line 45) and \texttt{requestLocationUpdates} 	(line 26-31) are their registration methods, respectively.\label{fig:code}
]{
   \includegraphics[width=0.65\linewidth]{images/code}
}
\hfill
\subfloat[
FCG of the code shown in \ref{fig:code}. Framework Space nodes are shown in Brown and Application Space nodes in Blue. Note that the registration methods \texttt{setOnClickListener} (node 17) and \texttt{requestLocationUpdates} (node 13) are not connected to their callback handlers \texttt{onClick} (node 22) and \texttt{onLocationChanged} (node 20), respectively. Also, their corresponding Framework Space callback methods (node 00 and node 01) are isolated from the rest of the nodes.
\label{fig:fcg}]{
   \includegraphics[width=0.3\linewidth]{images/fcg_wide}
}
\caption{A simple app along with its FCG, showing FCG not capturing interations between callback methods and their registration methods.}
\label{fig:simpleapp}
\end{figure*}

To include relationships between registration methods and callback handlers in the FCG, knowledge of the Framework space code is necessary @Cao2015 @DominguezPerez2017. Framework Space has to be analysed to obtain a mapping between of all possible registration and callback methods. This list has to be used while analysing the APK file to identify the implementation of callback methods as callback handlers, and associate them with their registration methods. This association has to be represented with a different _edge type_ in FCG, as it is different from  regular caller -- callee edge type. The presence of multiple edge types makes FCG _heterogenous_. The heterogenous FCG can be further enhanced by adding relationships between the Framework Space and Permissions. FCGs can contain enormous number of nodes and edges, depending on the size of the APK @Liu2018, which potentially affects the ability of the malware detection model to generalise well, promoting the need for reducing its size @Onwuzurike2019.

To perform deep learning on graphs, Graph Convolutional Networks (GCNs) @Kipf2017 have become a natural choice because of their flexibility @Zhang2018. GCNs process graphs by aggregating neighbourhood information and updating a node’s features based on it, along with learning parameters fine-tuned for a particular task. An $n$-layer GCN aggregates features into a node from its $n$-hop neighbourhood. The feature vector representing the graph is obtained by a global pooling operation on the graph. This vector can then be used for downstream tasks such as classification.

In this work, we analyse Framework space code to extract possible registration-callback method pairs motivated by the approach of @Cao2015. We also consider the mapping of permissions required by an API method from @Backes2016. These information are utilised while analysing APKs to convert FCGs extracted from them into _enhanced-FCGs_ (eFCGs). The _reduced-eFCG_ (R-eFCG) is then obtained by contracting nodes of eFCG, in an approach similar to MaMaDroid’s @Onwuzurike2019. Separate heterogeneous GCN models are then trained on eFCG and R-eFCG to evaluate their effectiveness.

We answer following research questions in this paper:

1. Which components of eFCG and R-eFCGs are essential in Android malware detection?
2. Can R-eFCGs achieve better generalisation in terms of detection rate than eFCGs?
3. What is the optimal neighbourhood size $n$ for GCNs to detect Android malware using eFCG and R-eFCGs?

To answer these research questions, we experiment with different components of eFCG and R-eFCGs to determine their contribution to the performance of the model. We also train separate models on eFCGs and R-eFCGs to access their generalisation ability. To determine the choice of optimal neighbourhood, we experiment by varying the number of GCN layers. As a result of these experiments, we obtained a maximum accuracy of 96.25% with R-eFCGs with all components and four GCN layers.

The key contributions of the present work are as follows:

1. We define eFCG and R-eFCG, containing the callback information and permission mappings along with caller-callee information, and provide algorithms to obtain the same.
2. We conducted an ablation study to find essential components of eFCG and R-eFCG, and found that all their components are essential.
3. We monitor the impact of the number of heterogeneous GCN layers on the performance of Malware Detector, and found that its performance increases with increasing number of layers.

   [//]: # "We integrated our Malware Detector with PGMExplainer [cite] to make it explainable and found that it provided satisfactory explanations most of the time."

Further sections of this paper are organised as follows: Several relevant related works are discussed in Section @sec:related-work. Section @sec:preliminaries provides an overview of mathematical concepts used in this paper. The Algorithms to obtain eFCG and R-eFCG along with the architecture of the Malware Detection model are described in Section @sec:proposed-approach. Experimental framework to evaluate the current work and its results are discussed in Section @sec:experiments.  The paper is concluded in Section @sec:conclusions along with discussing future directions.

# Related Work

The manifest can be used as a feature source to detect malware. Out of the features contained in the manifest, the permissions and intents were used to detect Android Malware in @Arp2014 @Kim2018 @Taheri2020 @Alazab2020. However, permissions extracted from the manifest are not conclusive, in a way that they need not be used in the app despite of being declared, which could lead to false positives during malware detection @Chen2020.

The dex code provides rich characteristics describing app behaviour. @Ren2020 represented the raw bytecode in the dex code in the form of a fixed size image and provided it as the input to Convolutional Neural Network based malware detector. Such representations completly ignore the structural information contained in the dex code, along with being prone to resizing losses.

The graphs extracted from dex code retain its structural information. Out of these graphs, the API Call Graph captures the call order between API methods. This was used a feature source in @Dam2017 @Pektas2020. API Call Graphs are easy to work with as they are of fixed size since number of API methods are limited. However, they can not capture complete behaviour of the app as they ignore user-defined methods.

FCGs capture caller-callee relationships between every method of the dex code, but are of huge magnitude @Liu2018. Therefore, they were not used as whole in many works @Liu2018 @Wu2019 @Gao2019. Of such works, @Wu2019 use Centrality measures of API methods, while @Gao2019 use graphlet frequency distribution as the feature vectors. Classifiers are trained with these feature vectors to detect malware. These works are limited in a sense that they only consider the structure of FCG, ignoring features that can be derived from method nodes.

@Liu2018 was one of the earliest work to associate node features with every node of the FCG. The feature vector was derived from the opcodes of the method, on which 1-hop neighbour XOR aggregation was performed. The aggregated feature vectors were clustered using $k$-Nearest Neighbours with $k=30$ to obtain cluster centres. These centres were used as the graph level feature vector. The approach of @Liu2018 is similar to the working of (1-layer) GCN in terms of neighbourhood aggregation, but it ignores the presence of API nodes completely, which are essential in accessing the behaviour of an app.

GCNs were used to detect Android malware based on FCGs in @Cai2021 @Yang2021 @Vinayaka2021. Of them, @Cai2021 used a word embedding based on method name was used as a node feature of the FCG, and conducted experiments on an imbalanced dataset. Node features of @Cai2021 are inefficient in the presence of obfuscation, as it mangles the method names. @Cai2021 used imbalanced dataset, which is known to induce biases on the performance of GCN-based classifiers @Vinayaka2021. 

API node subgraph of FCG, with centrality measures as node features were considered in @Yang2021. This graph was the input to GCN based classifer. Similar to @Dam2017 and @Pektas2020, @Yang2021 can not completely characterise the behaviour of the APK.

GCNs considering both API nodes and User nodes were used in @Vinayaka2021. Observing the potential biases that can be induced to GCN models in terms of imbalanced dataset and imblanced node size distribution among the classes, @Vinayaka2021 proposed a dataset balancing algorithm. @Vinayaka2021 consider both API nodes User nodes as a single type, and ignore callback information.

EdgeMiner @Cao2015 proposed a Framework Space code analysis method to extract registration-callback method pairs and added it to the FCG to extract potentially harmful paths in it. @DominguezPerez2017 provide a more granular view of the callback methods, considering the conditions for them to be _called back_. Similar analysis was performed in @Backes2016 to extract API method - Permission mappings. None of these works built an end-end malware detection pipeline.

# Preliminaries

This work uses several kinds of mathematical structures such as sets, functions and graphs. This section provides an overview of them along with discussing the structure of the dex code.

## Mathematical Collections 

A _set_ is an unordered collection of unique elements. If elements are allowed to be present in it multiple times, then it is called as a _multiset_. 

A _(binary) relation_ $R$ between two sets $A$ and $B$ is a subset of $A\times B$, i.e. $R\subseteq A\times B$. A _map_ (or function) $f:A\rightarrow B$ is a relation between $A$ and $B$ such that $\forall x\in A, y\in B\ \ (x,a) \in f \land (x,b) \in f \implies a=b$. A function can be thought of an association between a value $x\in A$ and a single value $y\in B$ if $(x,y)\in f$. A _multimap_ (or multifunction) is an extension to the function where several values $y\in Y$ can be associated with a single value of $x\in X$, i.e., $\forall x\in X\ \exists y \in Y\text{s.t. } (x,y) \in f$. 

The set of values (a single value, in case of maps) associated with $x\in X$ by $f$ is represented as $f(x)$. The domain of the function $f$ (represented as $\mathrm{dom}(f)$) is the set of values $x$ for which $f(x)$ is defined (in above examples, $\mathrm{dom}(f)=A$). Interested readers are referred to @Levin2021 for further information about set theory.

## Graphs

A _directed_ graph $G(V, E)$ is a collection of nodes $V$ and edges $(u,v)\in E$ where $u,v \in V$. A _multigraph_ is a graph in which $E$ is a multiset, allowing multiple edges between two nodes. A graph is _undirected_ if $(u,v) \in E \implies (v,u) \in E$. 

A path $p$ is a sequence of edges $e_1\rightarrow e_2\rightarrow \cdots \rightarrow e_n$ where every edge $e_i=(u_i,v_i)$ is distinct and $u_i=v_{i-1} \forall i>1$. Two nodes $x$ and $y$ are _connected_ in $G$ if there is a path between them. A graph is _acyclic_ if there are no paths in $G$ such that $u_1=v_n$. A _Directed Acyclic Graph (DAG)_ is a graph which is both directed and acyclic. As all these graphs consist of a single type of nodes and edges, they are _homogeneous_. Interested readers are referred to @Levin2021 for further information about graphs.

If a graph contains multiple types of nodes or edges (or both), then it becomes _heterogeneous_. Heterogeneous graphs occur naturally in many fields such as Recommender Systems @Wang2019 @Ying2018 and Bioinformatics @Li2020. The concept of heterogeneous graphs is illustrated here in light of Social Media Network shown in Figure @fig:socialmedia. Formally, a _directed heterogeneous graph_ is$G(\mathcal{V},\mathcal{E},V,E)$ where,

- $\mathcal{V}$ is the set of _node types_ (e.g, $\{\mathrm{person}, \mathrm{post}, \mathrm{tag}\}$),
-  $\mathcal{E}\subseteq \mathcal{V}^2$ is a multiset of _edge types_, each associated with a name (e.g, $\{\mathrm{likes}: (\mathrm{person},\mathrm{post}),\ \mathrm{follows}: (\mathrm{person},\mathrm{person}),\ \mathrm{authors} = (\mathrm{person},\mathrm{post}), \mathrm{follows}=(\mathrm{person}, \mathrm{tag}), \mathrm{tagged}:(\mathrm{post}, \mathrm{tag})\}$,
- $V=\cup_{t\in \mathcal{V}}V_t$ is the set of the nodes and,
- $E=\cup_{t\in \mathcal{E}}E_t$ is the set of edges.

An edge set can be denoted by name the name of its type followed by the nodes it connect to (e.g., $E_{\mathrm{follows}:\mathrm{person}\mapsto\mathrm{post}}$). The names of the nodes can be omitted if no other edge with the same name is present in the edge types (e.g., $E_\mathrm{likes}$, $E_\mathrm{authors}$). 

A heterogeneous graph becomes undirected if $\forall t=\in \mathcal{E},\ \exists t'\in \mathcal{E} \text{ s.t }\ (u,v)\in E_t \implies (v,u)\in  E_{t'}$. The structure of the heterogeneous graph is represented as a multigraph $G_M(\mathcal{V},\mathcal{E})$ called as the _metragraph_ of $G$ (See @fig:social_metagraph). Interested readers are referred to @Zhang2019 for further information about heterogeneous graphs.

If every node of the graph is associated with some attributes, then the graph is called as an _attributed graph._ The _attribute function_ $A_t:V_t\rightarrow \mathbb{A}_t$ defines the attributes for each node $v\in V_t$ in _attribute space_ $\mathbb{A}_t$. For homogeneous graphs, there is only one attribute space. 

\begin{figure}
\subfloat[A small heterogeneous graph representing a social media network. It consists of 3 types of nodes - $\mathrm{person}$, $\mathrm{post}$ and $\mathrm{tag}$, and 4 types of edges - $\mathrm{likes}$, $\mathrm{follows}:\mathrm{person}\mapsto\mathrm{person}$,$\mathrm{follows}:\mathrm{person}\mapsto\mathrm{tag}$, and $\mathsf{authors}$. \label{fig:socialgraph}]{
  \includegraphics[width=0.65\linewidth]{images/social_graph}
}\hfill
\subfloat[The metagraph of the heterogeneous graph shown in \ref{fig:socialgraph} \label{fig:social_metagraph}]{
  \includegraphics[width=0.65\linewidth]{images/social_metagraph}
}
\caption{A simple heterogeneous graph with its metagraph}
\label{fig:socialmedia}
\end{figure}

For a graph $G$ with nodes $V$ and edges $E$, we use following notations to denote the information about neighbourhood of $v\in V$ in $G$: $\{\mathrm{parents}_t\}_G(v) = \{u| (u,v)\in E \land v\in V_t\}$ is the set of $v$'s parents with type $t$, $\{\mathrm{children}_t\}_G(v) = \{w|(v,w)\in E\}$ is the set of its children with type $t$, $\{\mathcal{N}_t\}_G(v) = \{\mathrm{parents}_t\}_G(v) \cup \{\mathrm{children}_t\}_G(v)$ is the set of its 1-hop neighbours with type $t$. If $G$ is a DAG, $\mathrm{pred}_G(v) = \{u| u \text{ and } v \text{ are connected in } G\}$ is the set of predecessors of $v$, $\mathrm{succ}_G(v) = \{w| v \text{ and } w \text{ are connected in } G\}$ is the set of successors of $v$. In every notation, the suffix $G$ is omitted when the graph can be inferred from the context and, type suffix $t$ is omitted when we refer to nodes with all types.

## The dex file {#sec:dexfile}

The `classes.dex` present inside the APK contains the application logic represented as dex bytecode, which is then executed by Android Runtime @Source2021. Android API is also bundled in several dex files, residing in `/system/framework/framework.jar` in case of Android 11.

By parsing the dex file, one can obtain the sets of classes $\mathcal{C}$ and methods $\mathcal{M}$ implemented and referenced within its scope. Note that the _interfaces_ and _enums_ are treated as classes, and, the _constructors_ are treated as methods in the dex file.  The definition of every class $c \in \mathcal{C}$ and method $m\in \mathcal{M}$ associates them with several _flags_. These flags include _modifier_ information (e.g., `public`, `static` and `abstract`) and the declaration type in the code (e.g., `interface`, `enum` and `constructor`). The Boolean function ${is}F(\cdot)$ returns *true*  if the flag $F$ is present in the definition of its argument.

Apart from the flags, the definition of the class $c$ includes a list of its methods ($\mathrm{methods}(c)$), along with a list of its parents in the inheritance hierarchy ($\mathrm{parents(c)}$). The constructors of $c$ can be obtained by filtering its methods with the flag `constructor`, i.e., $\mathrm{constructors}(c) = \{m\ |\ m\in \mathrm{methods}(c)\ \land\ \mathrm{isConstructor}(m)\}$. Similarly, the definition of method $m$ includes the types of its arguments ($\mathrm{argumentTypes}(m)$) and a reference to the class to which it belongs to ($\mathrm{class}(m)$). Multiple methods in a class can have the same name due to method overloading; the method name along with its argument type list (the *signature*, denoted by $\mathrm{sig}(m)$) is unique for every method. If $m$ is internal, the dex code also includes their bytecode in dex format, where each opcode is of 8 bit length. Interested readers are referred to the Davlik Specification @Source2021 to get more information about the dex code.

Using the relationships among the methods $\mathcal{M}$ and classes $\mathcal{C}$ contained in the dex code, several graphs can be constructed. Out of them, the **Class-level Inheritance Graph** $\mathcal{I}^{(\mathsf{C})}(\mathcal{C}, E_\mathrm{parentOf}^{(\mathsf{C})})$, where $(c_i, c_j)\in E_\mathrm{parentOf}^{(\mathsf{C})} \iff c_i \in \mathrm{parents}(c_j)$, represents the inheritance hierarchy among the classes. The **(Method-level) Inheritance Graph** $\mathcal{I}^{(\mathsf{M})}(\mathcal{M}, E_\mathrm{parentOf}^{(\mathsf{M})})$ is obtained using $\mathcal{I}^{(\mathsf{C})}$ as 

\begin{equation}
\begin{split}
E_{\mathrm{parentOf}}^{(\mathsf{M})} = \{(m_i,m_j)\ | (&\mathrm{class}(m_i),\mathrm{class}(m_j) \in E_{\mathrm{parentOf}}^{(\mathsf{C})} \land \\ &\mathrm{sig}(m_i) = \mathrm{sig}(m_j) \}
\end{split}
\end{equation}.

 Note that the Inheritance Graphs $\mathcal{I}^{(*)}$ are DAGs, as are should be no cyclic dependencies among classes (thus methods) in terms of inheritance. The  **Function Call Graph** $\Gamma^{(\mathsf{M})}(\mathcal{M}, E_\mathrm{calls}^{(\mathsf{M})})$, where $(m_i,m_j)\in E_\mathrm{calls}^{(\mathsf{M})}$ if $m_i$ calls $m_j$ in its code, captures the caller-callee relationships among the methods in the dex code. The superscripts $(\mathsf{M})$ and $(\mathsf{C})$ indicate that the edges are among methods and class nodes, respectively. If the superscript is not present in the graph name (e.g., $\Gamma$ and $\mathcal{I}$), they are assumed to method-level.

# Proposed Approach

The proposed malware detection approach consists of two analysis stages -- Framework Space analysis and Application Space analysis, followed by a Heterogeneous GCN based malware detection model. The Framework Space analysis is done once and its outputs are re-used in the Application Space analysis for every app. Separate Heterogeneous GCN models are trained for eFCG and R-eFCG obtained by the Application Space analysis. Following sections describe every stage in detail.

## Framework Space Analysis

Framework space Analysis analyses the Android Framework to extract all possible registration-callback method pairs. To do so, the dex file containing Framework Space code has to be parsed to get the set of Framework Classes $\mathcal{C}_{\mathcal{F}}$ and Framework Methods $\mathcal{M}_\mathcal{F}$. From $\mathcal{C}_{\mathcal{F}}$ and $\mathcal{M}_\mathcal{F}$, the Framework Space Inheritance Graph $\mathcal{I}_\mathcal{F}$ and Framework Space FCG $\Gamma_\mathcal{F}$ are obtained, respectively. The approach of @Cao2015 is adopted to extract potential callback methods from the Framework Space code, which are then filtered to obtain final callback methods along with corresponding registration methods. The architecture of Framework Space Analysis is shown in Figure @fig:framework_analysis.

![The workflow of Framework Space Analysis](images/framework_analysis.pdf){#fig:framework_analysis fullwidth=1 width=0.8}

### Potential Callback Filter {#sec:potentialFilter}

A potential callback method is a Framework space method which is visible to the Application space and can be overridden by it. For a method $m$ with $c=\mathrm{class}(m)$, if all of the following criterion are satisfied, then it becomes a potential callback method @Cao2015:

1. $\mathrm{isPublic}(c) = 1$
2. $\mathrm{isFinal}(c) = 0$
3. $\mathrm{isInterface}(c) = 1\ \lor\ \lor_{x\in \mathrm{constructors}(c)}\mathrm{isPublic}(x)$
4. $\mathrm{isPublic}(m) = 1 \lor \mathrm{isProtected}(m) = 1$

Criterion 1, 2 and 3 ensure that the class $c$ is visible to Application Space classes and can be extended; Criteria 4 ensures that the method $m$ can be overridden in Application Space. As all interface methods are public by default, Criteria 4 is true for them. The set of all potential callbacks is denoted by $P$.

### Registration-Callback Map Extraction {#rcPairs}

A method $m$ being potential callback does not guarantee that its Application Space override $m'$ can be *introduced* back to the Framework Space by means of an Application Space visible registration method $r$ and, subsequently called back by the Framework Space. Note that to *introduce* $m'$ to $r$, the method $r$ must take an argument of type $c = \mathrm{class}(m)$, thus accepting any instance of class $c'$ derived from $c$, overriding $m$ in its method $m'$. 

To filter out the methods $m$ whose overrides can not be introduced to Framework Space, we use _Argument Map_. The **Argument Map** is a multimap $\mathcal{A}_\mathcal{F}:\mathcal{C}_\mathcal{F}\rightarrow \mathcal{M}_\mathcal{F}$, where $(c,m) \in \mathcal{A}_\mathcal{F} \iff c\in \mathrm{argumentTypes}(m)$. In other words, for a Framework Space class $c$, $\mathcal{A}_\mathcal{F}(c)$ is a set of methods $M\subset \mathcal{M}_\mathcal{F}$, in which $c$ is an argument of. If $\mathcal{A}_\mathcal{F}(c)=\Phi$ for $c=\mathrm{class}(m)$, then the class $c$ can not be passed back to the Framework Space, therefore all of its methods are not callback methods.

A registration method $r$ taking an argument of type $c$ need not necessarily invoke the method $m$ of $c$. To check for the invocation of $m$, a complete _reverse data-flow analysis_ tracking $c$ until the invocation of $m$, is required as in @Cao2015. However, we empirically observe that the invocation of $m$ happens in a method $\mu$ either belonging to $u=\mathrm{class}(r)$ or some nested class $u'$ of $u$ most of the times. Therefore, the criterion to consider the method $m$ with $c=\mathrm{class}(m)$ as a final callback method are defined as follows:

1. $c$ is an argument of some Application Space visible method $r$. i.e., $\exists\ r\in \mathcal{A}_\mathcal{F}(c)\ \text{ s.t. } \mathrm{isPublic}(r) \land \mathrm{isPublic}(\mathrm{class}(r))$, and,
2. Some method $\mu$ either belonging to $u=\mathrm{class}(r)$ or some nested class $u'$ of $u$ invokes $m$ in its code.

If a method $m$ satisfies above criterion, then the method $r$ is the *registration method* of $m$ and, the pair $(r,m)$ is added to the Registration-Callback map $\mathcal{R}$. The process of extracting Registration-Callback map is summarised in Algorithm 1.

\begin{algorithm}
\footnotesize
\begin{algorithmic}[1]
\Procedure{AnalyseFramework}{$\mathcal{C}_\mathcal{F}, \mathcal{M}_\mathcal{F}$}
\LineCommentCont{Extract the Registration-Callback map $\mathcal{R}$ using $\mathcal{C}_\mathcal{F}$ -- Set of Framework Space Classes and $\mathcal{M}_\mathcal{F}$ -- Set of Framework Space Methods.}
\State{$\mathcal{I}_\mathcal{F}\gets$ Extract Inheritance Graph using $\mathcal{C}_\mathcal{F}$} \Comment{See Section \ref{sec:dexfile}}
\State{$\Gamma_\mathcal{F}\gets$ Extract FCG using $\mathcal{M}_\mathcal{F}$}\Comment{See Section \ref{sec:dexfile}}
\State{$\mathcal{A}_\mathcal{F}\gets$ Extract Argument Graph using $\mathcal{M}_\mathcal{F}$ and $\mathcal{C}_\mathcal{F}$}\Comment{See Section \ref{rcPairs}}
\State{$P \gets$ Extract Set of Potential Callbacks from $\mathcal{M}_\mathcal{F}$}\Comment{See Section \ref{sec:potentialFilter}}
\State{$C_P\gets \Phi$}\Comment{Multimap of methods in $P$ keyed by their class}
\For{$m$ in $P$}
\If{$\exists u\text{ s.t. } (\mathrm{class}(m), u)\in \mathcal{A}_\mathcal{F}$}\LineCommentCont{check if $\mathrm{class}(m)$ is used anywhere}
\State{$C_P\gets C_P\cup (\mathrm{class}(m), m)$}
\EndIf
\EndFor
\State{$\mathcal{R}\gets\Phi$}\Comment{Registration Callback Pairs}
\For {$c$ in $\mathrm{dom}(C_P)$}
\State{$R\gets \{(\mathrm{class}(r), r)\ |\ r \in \mathcal{A}_\mathcal{F}(c) \land \mathrm{isPublic}(r) \land \mathrm{isPublic}(\mathrm{class}(r))\}$} \Comment{Multimap of possible registration methods for class $c$ keyed by their classes}
\For{$p$ in $C_P(c)$}\Comment{Loop through Potential Callback methods $p$ of class $c$}
\State{$U\leftarrow \{\mathrm{class}(u)\ |\ u\in \mathrm{parent}_{\Gamma_\mathcal{F}}(p) \}$}\LineCommentCont{Set of classes that have at least one method calling $p$}
\State{$\mathcal{R} \gets \mathcal{R} \cup \{(r,p)\ |\ c\in (U\cap\mathrm{dom}(R))\ \land\ r\in R(c)\}$} \LineCommentCont{Update Registration-Callback map considering the classes that call $p$ and have registration method containing $c$ in their argument. Note that the $\cap$ operation is \textit{approximate} (see Section \ref{rcPairs}).}
\EndFor
\EndFor
\State{\textbf{return} $\mathcal{R}$, $\mathcal{I}_\mathcal{F}$}
\end{algorithmic}
\caption{ Framework Space Analysis}
\end{algorithm}


Note that whenever $r$ is a registration method, its any Framework Space child $r'$ can be a registration method too, assuming that $r'$ invokes $r$ with its parameters. Therefore, $(r, p)\in \mathcal{R} \implies (r',p)\in \mathcal{R}$. As adding $(r',p)$ to registration-callback pairs $\mathcal{R}$ increases the size of $\mathcal{R}$ significantly,  Framework Space Inheritance Graph $\mathcal{I}_\mathcal{F}$ is provided to Application Space Analysis, to infer such relationships.

## Application Space Analysis {#sec:app_analysis}

Application Space analysis extracts the dex file from the APK and parses it to get the set of Application Space classes and methods $\mathcal{C}_\mathcal{A}$ and $\mathcal{M}_\mathcal{A}$, respectively. Note that the $\mathcal{C}_\mathcal{A}$ (and $\mathcal{M}_\mathcal{A}$) includes the classes (and methods) implemented in Application Space $C_\mathcal{A}$ ($M_\mathcal{A}$), along with the reference to classes (methods) from Framework Space $C_\mathcal{F} \subset \mathcal{C}_\mathcal{F}$ ($M_\mathcal{F} \subset \mathcal{M}_\mathcal{F}$). Therefore, $\mathcal{C}_\mathcal{A}=C_\mathcal{A}\cup C_\mathcal{F}$ and $\mathcal{M}_\mathcal{A}=M_\mathcal{A}\cup M_\mathcal{F}$. The $\mathcal{M}_\mathcal{A}$ and $\mathcal{C}_\mathcal{A}$ are used to derive Application Space FCG $\Gamma_\mathcal{A}\left(\mathcal{M}_\mathcal{A}, E_{\mathrm{calls}}^{(\mathsf{M})}\ \right)$ and Application Space Method level Inheritance Graph $\mathcal{I}_\mathcal{A}\left(\mathcal{C}_\mathcal{A}, E_{\mathrm{parentOf}}^{(\mathsf{M})}\right)$, respectively. As the the methods in $M_\mathcal{F}$ are only references, their inheritance information is not contained in $\mathcal{I}_\mathcal{A}$.

The Application Space Analysis proceeds through several stages, each enriching the FCG, converting it to eFCG $\Gamma_e$ at the end. The eFCG is then reduced into R-eFCG $\Gamma_e^{(\mathsf{C})}$ using eFCG reducer. These stages are outlined in Figure @fig:app_analysis and described in detail in the following paragraphs.

![Stages in Application Space Analysis](images/application_analysis.pdf){#fig:app_analysis width=0.7}

### Inheritance Edges Adder

The event handlers are implemented in the Application Space as a overridden method of a Framework Space callback method. The FCG is unable to capture this information as the event handler does not call its parent callback method most of the times.

To add the relationship between event handler and its parent callback method to the FCG, the inheritance hierarchy has to be considered. By adding the edges in $E_{\mathrm{parentOf}}^{(\mathsf{M})}$ contained in Method level Inheritance Graph $\mathcal{I}_\mathcal{A}$, the event handlers are connected to their parent callback methods, along with connecting Application Space methods to their parents.

### Callback Edges Adder

The registration methods and the callback methods are not related in the FCG, as their caller-callee relationship can not be inferred without the help of the results of Framework Space Analysis.

The Registration Callback map $\mathcal{R}$ can be used to add edges between the registration methods and the corresponding callback methods. As the Framework Space inheritance information is not contained in $\mathcal{I}_\mathcal{A}$ (thus in $E_{\mathrm{parentOf}}^{(\mathsf{M})}$), $\mathcal{I}_\mathcal{F}$ has to be considered while adding callback edges.

For every Framework Space method $m$ in $M_\mathcal{F}$, with the help of $\mathcal{R}$ and $\mathcal{I}_\mathcal{F}$, it is determined whether $m$ is a registration method. If so, the corresponding callback methods $P$ are obtained. The edges between $m$ and the callback method $p\in P$ is added if $p\in M_\mathcal{F}$. The process of obtaining callback edges $E_{\mathrm{callsBack}}^{(\mathsf{M})}$ is detailed in Algorithm \ref{algo:cb-edges}.

\begin{algorithm}
\footnotesize
\begin{algorithmic}[1]
\Procedure{GetCallbackEdges}{$\Gamma_\mathcal{A}, \mathcal{I}_\mathcal{F},
\mathcal{R}$}
\LineCommentCont{Get a list of callback edges $E_{\mathrm{callsBack}}^{(\mathsf{M})}$ using Application Space FCG $\Gamma_\mathcal{A}$, Framework Space Method level Inheritance Graph $\mathcal{I}_\mathcal{F}$, and Registration Callback map $\mathcal{R}$.}
\State{$E_{\mathrm{callsBack}}^{(\mathsf{M})}\gets \Phi$}
\For{$m$ \textbf{in} $M_\mathcal{F}$}
	\For{$p$ \textbf{in} $\{m\}\cup\mathrm{pred}_{\mathcal{I}_\mathcal{F}}(m)$}
    	\If{$p\in \mathrm{dom}(\mathcal{R})$}
\State{$E_{\mathrm{callsBack}}^{(\mathsf{M})}\gets E_{\mathrm{callsBack}}^{(\mathsf{M})} \cup \{ (m,c) \ |\ c\in\mathcal{R}(p)\land c\in M_\mathcal{F} \}$}
		\EndIf
	\EndFor
\EndFor
\State{\textbf{return} $E_{\mathrm{callsBack}}^{(\mathsf{M})}$}
\end{algorithmic}
\caption{Callback Edge Addition} \label{algo:cb-edges}
\end{algorithm}

### Permission Nodes Adder

The manifest file contains a list of permissions that are required by an app to run. As it is possible to request a permission and not use it @Chen2020, permissions required by used Framework Space methods can be used to get a list of actual permissions needed. Axtool @Backes2016 provides a mapping $\Psi:\mathcal{M}_\mathcal{F}\rightarrow\mathcal{P}$ between Framework Space methods $\mathcal{M}_\mathcal{F}$ and Permissions they use. For a Framework method $m\in M_\mathcal{F}$, $\Psi(m)$ is the set of permissions that is required by $m$. 

The permission nodes $P$ and the edges $E_{\mathrm{requires}}^{(\mathsf{M})}$ to be added to the FCG are calculated as follows:
$$
P=\bigcup_{m\in M_{\mathcal{F}}} \Psi(m)
$$ {#eq:1}

$$
E_\mathrm{requires}^{(\mathsf{M})} = \{(m,p)\ | \ m\in M_{\mathcal{F}} \land p\in \Psi(m)\}.
$$ {#eq:2}



### Node Attributes Assigner {#sec:efcg}

After adding inheritance edges, callback edges and permission nodes and edges, the FCG becomes heterogeneous. The nodes of it consists of Application Space methods $M_\mathcal{A}$, Framework Space methods $M_\mathcal{F}$, and Permissions $P$. The edges $E_{\mathrm{calls}}^{(\mathsf{M})}$ can be partitioned into $E_{\mathrm{calls}:\mathcal{A}\mapsto\mathcal{A}}^{(\mathsf{M})}$ and $E_{\mathrm{calls}:\mathcal{A}\mapsto\mathcal{F}}^{(\mathsf{M})}$ to represent the relationships between the methods in different spaces. Similarly, the edges $E_{\mathrm{parentOf}}^{(\mathsf{M})}$ can be partitioned into $E_{\mathrm{parentOf}:\mathcal{A}\mapsto\mathcal{A}}^{(\mathsf{M})}$ and $E_{\mathrm{parentOf}:\mathcal{F}\mapsto\mathcal{A}}^{(\mathsf{M})}$. The edges $E_{\mathrm{callsBack}}^{(\mathsf{M})}$ are always among Framework Space methods $M_\mathcal{F}$. Similarly, the edges $E_{\mathrm{requires}}^{(\mathsf{M})}$ are always from Framework Space methods to Permissions $\mathcal{P}$. 

Using these partitions, the Enhanced FCG (eFCG) can be formally defined as a heterogeneous graph $\Gamma_e(\mathcal{V}, \mathcal{E},V^{(\mathsf{M})}, E^{(\mathsf{M})})$ where, 

- $\mathcal{V}=\{\mathcal{F}, \mathcal{A}, \mathcal{P}\}$ is the set of node types,
- $\mathcal{E}=\{\mathrm{calls}:(\mathcal{A}, \mathcal{A}), \mathrm{calls}:(\mathcal{A}, \mathcal{F}), \mathrm{parentOf}:(\mathcal{A}, \mathcal{A}), \mathrm{parentOf}:(\mathcal{F}, \mathcal{A}), \mathrm{callsBack}: (\mathcal{A}, \mathcal{A}), \mathrm{requires}:(\mathcal{F}, \mathcal{P}) \}$ is the set of edge types,
- $V_\mathcal{F}^{(\mathsf{M})}=M_\mathcal{F}$, $V_\mathcal{A}^{(\mathsf{M})}=M_\mathcal{A}$, and $V_{\mathcal{P}}^{(\mathsf{M})}=P$ are the sets of nodes, and
- $E_{\mathrm{calls}:\mathcal{A}\mapsto\mathcal{A}}^{(\mathsf{M})}$, $E_{\mathrm{calls}:\mathcal{A}\mapsto\mathcal{F}}^{(\mathsf{M})}$, $E_{\mathrm{parentOf}:\mathcal{A}\mapsto\mathcal{A}}^{(\mathsf{M})}$, $E_{\mathrm{parentOf}:\mathcal{F}\mapsto\mathcal{A}}^{(\mathsf{M})}$, $E_\mathrm{callsBack}$ and $E_\mathrm{requires}$ are the sets of edges.

The metagraph $\{\Gamma_e\}_M$ of the eFCG is shown in Figure @fig:metagraph.

![Metagraph $\{\Gamma_e^{(*)}\}_M$ of eFCG and R-eFCG](images/metagraph.pdf){#fig:metagraph width=0.7}

For every node, the attributes are assigned using attribute scheme $A$ as follows:

- For Framework Space nodes $m$, $A_\mathcal{F}(m)$ is a one-hot vector describing the position of $m$ in the API methods list obtained from @AndroidDevelopers2021.
- For Application Space nodes $m$, $A_\mathcal{A}(m)$ is a 21 bit Boolean vector representing the opcode groups that are used in its body as in @Vinayaka2021.
- For Permission nodes $p$, $A_\mathcal{P}(p)$ is a concatenation of a one hot vector of the group that it belongs to, and a bit indicating whether it is dangerous or not @AndroidSource2021.

The attributes are assigned as a vector $\mathbf{h}_i^{(0)}$ for every node $i$.

### eFCG Reduction

As the eFCG $\Gamma_e$ contains large number of nodes and edges, the ability of the malware detection model to generalise might be limited @Onwuzurike2019. To overcome this problem, the method nodes ($\mathcal{F}$ and $\mathcal{A}$) are contracted depending the classes as in MaMaDroid @Onwuzurike2019 to get Reduced-eFCG (R-eFCG). Formally, R-eFCG is $\Gamma_e^{(\mathsf{C})}(\mathcal{V},\mathcal{E}, V^{(\mathsf{C})}, E^{(\mathsf{C})})$ where,

- $\mathcal{V}$ and $\mathcal{E}$ carry the same meaning as in eFCG (See Section @sec:efcg),
- $V_t^{(\mathsf{C})}=\{ \mathrm{class}(m)\ |\ m\in V_t^{(\mathsf{M})}  \}$ for $t\not=\mathcal{P}$, and
- $E_t^{(\mathsf{C})}=\{(\mathrm{class}(m_i), \mathrm{class}(m_j)\ |\ (m_i,m_j)\in E_t^{(\mathsf{M})}\}$ for $t\not=\mathrm{requires}$, $E_{\mathrm{requires}}^{(\mathsf{C})}=\{(\mathrm{class}(m),p)\ |\ (m,p)\in E_\mathrm{requires}^{(\mathsf{M})}\}$.

The attributes of the class nodes are derived by *binary-OR*ing the node attributes of their member methods. The eFCG and R-eFCG of the simple app shown in Figure @fig:code is illustrated in Figure @fig:eFCG. Observe that the registration methods and callback handlers are connected through callback methods in eFCG.

\begin{figure*} \subfloat[eFCG]{\includegraphics[width=0.55\linewidth]{images/efcg/efcg}} \hfill \subfloat[R-eFCG]{\includegraphics[width=0.35\linewidth]{images/efcg/refcg}} \caption{eFCG and R-eFCG of the simple app shown in in Figure \ref{fig:code}. Blue circles represent nodes in $\mathcal{A}$, brown diamonds represent nodes in $\mathcal{F}$, and pink squares represent node in $\mathcal{P}$. Caller-callee relationships are represented in black soild edges, callback relationships in red bold edges, inheritance relationships in blue dashed edges, and, permission relationships are represeted in green edges. Note that the node numbering is same as Figure \ref{fig:fcg} \label{fig:eFCG}}\end{figure*}

## GCN Classifier

The GCN Classifier consists of Several Heterogeneous GCN layers, each containing a GCN module for every edge type. The eFCG and R-eFCGs are converted into undirected graphs beforehand by adding a reverse edge type for every edge type present in the graph, to ensure that data flow happens between every type of node.

Every GCN module is implemented using `GraphConv` algorithm @Kipf2017. At every layer $l$, the hidden representation $\mathbf{h}_i^{(l+1)}$ of node $i$ with type $s\in \mathcal{V}$ is first calculated using GCN module of edge $e$ where $e=(s,t),\ e\in \mathcal{E}$ using following operations:
$$
\{\mathbf{h}_{i}^{(l+1)}\}_e = \sigma\left( \mathbf{b}^{(l)} + \sum_{j\in \mathcal{N}_t(i)}\frac{1}{c_{ij}}\mathbf{h}_{j}^{(l)}\mathbf{W}^{(l)}\right)
$$ {#eq:edge_conv}

$$
\mathbf{h}_i^{(l+1)} = \sum_{e\in \mathcal{E}}\{\mathbf{h}_i^{(l+1)}\}_e
$$ {#eq:agg}

where,
$$
c_{ij}=\frac{1}{\sqrt{|\mathcal{N}_t(i)|\times |\mathcal{N}_s(j)|}}
$$
is the normalisation coefficient between node $i$ and node $j$, $\sigma$ is an activation function ($\mathrm{ReLu}$ in this work), $\mathbf{W}^{(l)}$ and $\mathbf{b}^{(l)}$ are the weight and bias matrices at layer $l$, respectively. After $n$ convolution layers, the node features of node type $t$ are aggregated using a *readout* operation (*mean* in this work) to get $\mathbf{h}_t$. The readout features for all node types $t\in\mathcal{V}$ are then concatenated (operator $||$) to get a graph-level embedding vector $\mathbf{h}$. These operations are summarised as follows:
$$
\mathbf{h}_t=\frac{1}{|V_t|}\sum_{\ i\in V_t}\mathbf{h}_i^{(n)}
$$ {#eq:node_readout}
and
$$
\mathbf{h} = \underset{t\in\mathcal{V}}{\large\|}\mathbf{h}_t.
$$ {#eq:concat}
The graph embedding $\mathbf{h}$ can be passed to any downstream task. This work uses a 1-layer fully connected neural network followed by the sigmoid activation function as the classifier. Thus, the probability of a given eFCG (or R-eFCG) is from malware APK can be given as,
$$
P\left(\mathrm{Malware}|\Gamma_e^{(*)}\right)=\mathrm{sigmoid}(b+\mathbf{h}\mathbf{W}).
$$ {#eq:linear}
where $\mathbf{W}$ and $b$ are the weight matrix and bias of the classifier, respectively. For classification purposes, if $P>0.5$, the sample is regarded as malware, otherwise benign.

# Experiments, Results and Analysis {#sec:experiments}

The experiments to answer the research questions posed in Section @sec:intro are described in this section along with the configurations.

## Software Configuration

APK processing and heterograph extraction was performed using Androguard @ADT2021. Heterograph extraction was parallelised using JobLib @JDT2021. GCNs were implemented and trained using Deep Graph Library @Wang2019a on top of PyTorch @Paszke2019 and PyTorch-Lightning @Falcon2019, with runs tracked using Weights & Biases @Biewald2020.

## Datasets used

Maldroid2020 @Mahdavifar2020 and AndroZoo @Allix2016 datasets were used to train the model. The dataset balancing approach of @Vinayaka2021 was applied on Maldroid2020, with adding additional APKs from AndroZoo. The final dataset was balanced both in terms of number of APKs and node count distribution and contained a total of 11760 APKs. The dataset was divided into training and testing splits with ratio 80% and 20%, respectively, while ensuring that the node count distribution of both splits remained the same. 

## Training Configuration 

Every GCN model was trained using Binary Cross Entropy loss function, as the model was learning a probability distribution. Adam Optimiser @Kingma2015 was used to optimise the parameters of the model as it performs better than other optimisers, even in its default configuration (learning rate=$10^{-3}$). Maximum number of epochs was set to 100 and the model at epoch $e$ having minimum validation loss was chosen for testing.

## Experiments

### Ablation Study

To determine the essential node types of eFCG and R-eFCG, ablation study was conducted by restricting the node types $\mathcal{V}$ to -- $\mathrm{code} = \{\mathcal{A}\}$, $\mathrm{core}=\{\mathcal{A}, \mathcal{F}\}$ and $\mathrm{all}=\mathcal{V}\overset{\mathrm{def}}{=}\{\mathcal{F},\mathcal{A},\mathcal{P}\}$. The GCN models are trained and tested using this reduced set of node types. Note that the Application Space nodes $\mathcal{A}$ are present in all sets as they contain crucial logic that can be used as a behaviour indicator of an app. Thus, the ablation study aims to test whether Framework and Permission nodes improve the performance of the model significantly.  

### Neighbourhood Analysis

Every node configuration was trained with variable number of Heterogeneous GCN layers starting from $n=0$, to test whether increasing number of GCN layers (thus, a larger neighbourhood) improves the performance of model. The case of $n=0$ represents the set of baseline models in which aggregated and concatenated node attributes are directly passed as the input to sigmoid classification model. 

### Generalisation Analysis

Every configuration in ablation study and neighbourhood analysis was conducted both for eFCG and R-eFCG, by training seperate GCNs on them. These experiments were used to determine whether R-eFCG performs better than eFCG, implying its ability to generalise.

## Results and Analysis

Summary of the experimental results are shown in Table \ref{tab:res}. From it, several insights about research questions can be drawn, which are discussed in following sections.

\input{images/table}

### Effectiveness of Node types

With Application Space nodes $\mathcal{A}$ only, the model was able to achieve a mean accuracy of 84.63% with a standard deviation of 7.79%. With the addition of framework space nodes $\mathcal{F}$, the mean accuracy was increased by 6.86%, reaching 91.49% with a standard deviation of 4.29%. The addition of permission nodes slightly improved the mean accuracy by 1.58%, making the model achieve a mean accuracy of 93.07% with a standard deviation of 4.02%. The trend of increasing accuracy with addition of node types is shown in Figure @fig:acc_nodetype. These results emphasise that the Framework Space nodes are crucial to detect Android Malware. Similarly, the contribution of permission nodes to the performance of the model is important, although the they are less in number.

![Mean and Standard Deviation of Accuracy of the model for different node type configurations.](images/acc_nodetype.pdf){#fig:acc_nodetype width=0.7}

### Effect of neighbourhood size $n$

With $n=0$, the baseline models performed better than a random-guess models obtaining a mean accuracy of 80.35% with standard deviation of 7.60%, suggesting that the node attributes play an important role to detect malware. Subsequent addition of GCN layers improved the mean accuracy by 9.29%, 2.49%, 0% and, 1.27%, respectively. No performance improvements were observed during the addition of third GCN layer for "$\mathrm{core}$" and "$\mathrm{all}$" configurations. Addition of fourth GCN layer did not improve the accuracy by a significant amount. The variation of accuracy with the addition of GCN layers shown in Figure @fig:acc_n suggests that $n=2$ is a sweet spot between accuracy and inference time, as the number of GCN layers directly affect the inference time.

![Mean Accuracy of the model containing $n$ GCN layers. Shaded area represents the standard deviation of accuracy.](images/acc_n.pdf){#fig:acc_n width=0.7}

### Generalisation ability of R-eFCG

R-eFCGs performed better then eFCGs all node configurations as evident from Table \ref{tab:res}. A statistical analysis of the accuracies obtained with eFCGs and R-eFCGs suggest that the R-eFCGs improve the mean accuracy by 2.35% with a standard deviation of 1.25%. Minimum improvements less than 1% were observed with $n=4$ and node configuration "$\mathrm{code}$" and "$\mathrm{all}$" along with $n=2$ with node configuration "$\mathrm{all}$".

These results suggest that R-eFCGs are able to generalise better than eFCGs in most of the cases. In the _sweet spot_ $n=2$ with node configuration $\mathrm{all}$, R-eFCGs can be used as a replacement to eFCGs, thus making inference faster, as they have fewer nodes than eFCGs. Note that R-eFCG $\Gamma_e^{(\mathsf{C})}$ has to be calculated after $\Gamma_e$ (see Section @sec:app_analysis), thus adding additional computational step. However, the procedure of Section @sec:app_analysis can be easily tuned to output R-eFCGs instead of eFCGs by considering classes instead of methods, and using their attribute schemes.

### Comparison with Related Works {.unnumbered}

The "$\mathrm{core}$" configuration of this work using eFCGs is conceptually similar to FCGs used in @Vinayaka2021. While @Vinayaka2021 reported an accuracy of 92.29% with 3 GCN layers, the "$\mathrm{core}$" configuration using eFCGs with $n=3$ achieved a similar accuracy 92.08%. The proposed method could not be compared with @Cai2021 @Yang2021 as they did not incorporate any node-count distribution balancing strategies and, did not disclose their dataset.

# Conclusions and Future Work {#conclusions}

In this paper, an Android Malware detection scheme based on the heterogenous calleer-callee graphs extracted from the APK files was proposed. The heterogeneous graphs eFCG and R-eFCG were defined and algorithm to obtain the same were discussed. These graphs incorporate the information about callback and permissions, obtained by the Framework Space Analysis. Separate heterogeneous graph models were trained on them to evaluate their performance. Along with this, the experiments to determine optimal neighbourhood and essential components of heterogeneous graphs were also conducted. As a result of these experiments, a maximum accuracy of 96.28% was obtained.

There is further scope to improve this work in multiple directions. During Framework Space analysis, the algorithm to find registration-callback pairs can be made more exact, and their difference of their results with our approximate method can be compared and contrasted. In Application Space analysis, the nodes can be assigned more informative features, such as opcode sequence embedding. Explanability methods can be integrated with the GCN models to identify and understand critical nodes that contain malicious code.

