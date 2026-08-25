# 🐍 OphidIA

Repositório contendo o desenvolvimento de um projeto acadêmico (TCC) do curso de Ciência da Computação, cujo objetivo é desenvolver um **aplicativo mobile multiplataforma** que utiliza **Visão Computacional** e **Deep Learning** para classificar espécies de serpentes brasileiras a partir de imagens, fornecendo informações rápidas e educativas para a população — especialmente em áreas rurais — auxiliando na identificação correta da espécie e nas ações iniciais a serem tomadas em casos de acidentes ofídicos.

Este trabalho foi submetido ao **CONIC-SEMESP** (Congresso Nacional de Iniciação Científica), na categoria "Em Andamento".

> 🇺🇸 **[Read this in English](#-ophidia-1)**

---

## 📱 Telas do Aplicativo

> **COLOCAR TELAS AQUI DO APP**

---

## 🎯 Objetivo

Desenvolver um aplicativo móvel capaz de identificar e classificar espécies de serpentes brasileiras por meio de redes neurais profundas (Deep Learning) com análise de imagens, fornecendo informações que auxiliem a população no reconhecimento das espécies em casos de acidentes ofídicos.

### Objetivos Específicos
- Aquisição, seleção, organização e preparação de imagens de serpentes brasileiras provenientes de bases de dados públicas, estruturando um dataset adequado ao treinamento;
- Desenvolvimento de um modelo de classificação baseado na arquitetura **EfficientNet**, empregando *transfer learning* para identificação da espécie a partir de fotos enviadas pelo usuário;
- Implementação de um aplicativo multiplataforma que permita capturar, enviar imagens e receber informações sobre a espécie identificada;
- Avaliação do desempenho do modelo por meio de métricas como acurácia e perda (*loss*), analisando sua confiabilidade e robustez;
- *(Próxima fase)* Desenvolvimento de um modelo de detecção com a arquitetura **YOLO**, para localização do animal na imagem antes da classificação.

---

## ⚙️ Funcionalidades

- **Identificação por imagem**: classificação de espécies de serpentes brasileiras via captura de câmera ou upload da galeria do dispositivo;
- **Informações da espécie**: exibição de dados sobre a espécie identificada e tipo de soro eficaz em casos de acidente ofídico;
- **Visualização geográfica**: exibição de registros e ocorrências de serpentes próximas ao usuário através de integração com o Google Maps Platform.

---

## 🧠 Metodologia (resumo)

O modelo de classificação foi desenvolvido com a arquitetura **EfficientNet-B3**, pré-treinada na ImageNet, utilizando *transfer learning* e *fine-tuning* sobre um dataset próprio construído a partir das bases públicas **SnakeCLEF** e **iNaturalist**. Nesta etapa, o escopo foi restrito ao gênero *Bothrops*, responsável pela maioria dos acidentes ofídicos registrados no Brasil.

O treinamento foi conduzido ao longo de 60 épocas, com *data augmentation* via biblioteca **Albumentations** e amostragem ponderada para mitigar o desbalanceamento entre classes. Nos resultados preliminares, o modelo atingiu **85,84% de acurácia no top 3** e **70,03% no top 1**.

---

## 🛠️ Tecnologias Utilizadas

### Frontend
- **Framework**: Flutter
- **Linguagem**: Dart

### Backend / IA
- **Linguagem**: Python
- **API**: FastAPI
- **Deep Learning**: PyTorch
- **Arquitetura de classificação**: EfficientNet-B3 (*transfer learning* + *fine-tuning*)
- **Arquitetura de detecção**: YOLO *(prevista para a próxima fase)*
- **Data augmentation**: Albumentations
- **Datasets**: SnakeCLEF, iNaturalist

### Infraestrutura
- **Banco de dados / armazenamento**: Supabase
- **Geolocalização**: Google Maps Platform

---

## 👥 Consultoria Técnica

O projeto contou com o apoio de um pesquisador do **Instituto Butantan** para validação da relevância prática dos resultados.

---

## 📄 Artigo Científico

O artigo completo submetido ao CONIC-SEMESP está disponível no repositório.

---

<br>

# 🐍 OphidIA

Repository containing the development of an academic capstone project (undergraduate thesis) for a Computer Science degree, aimed at developing a **cross-platform mobile application** that uses **Computer Vision** and **Deep Learning** to classify Brazilian snake species from images, providing quick and educational information for the population — especially in rural areas — assisting in the correct identification of the species and the initial actions to be taken in the event of snakebites.

This work was submitted to **CONIC-SEMESP** (National Congress of Scientific Initiation), in the "Work in Progress" category.

---

## 📱 App Screens

> **ADD APP SCREENSHOTS HERE**

---

## 🎯 Objective

Develop a mobile application capable of identifying and classifying Brazilian snake species through deep neural networks (Deep Learning) with image analysis, providing information to help the population recognize species in cases of snakebite accidents.

### Specific Objectives
- Acquisition, selection, organization, and preparation of Brazilian snake images from public databases, structuring a dataset suitable for training;
- Development of a classification model based on the **EfficientNet** architecture, using *transfer learning* to identify the species from photos submitted by the user;
- Implementation of a cross-platform application that allows users to capture, upload images, and receive information about the identified species;
- Evaluation of model performance using metrics such as accuracy and loss, to assess its reliability and robustness;
- *(Next phase)* Development of a detection model using the **YOLO** architecture, to locate the animal in the image prior to classification.

---

## ⚙️ Features

- **Image identification**: classification of Brazilian snake species via camera capture or gallery upload;
- **Species information**: display of data about the identified species and the effective antivenom serum type in cases of snakebite accidents;
- **Geographic visualization**: display of nearby snake sighting records via Google Maps Platform integration.

---

## 🧠 Methodology (summary)

The classification model was developed using the **EfficientNet-B3** architecture, pretrained on ImageNet, using *transfer learning* and *fine-tuning* on a custom dataset built from the public **SnakeCLEF** and **iNaturalist** databases. At this stage, the scope was restricted to the *Bothrops* genus, responsible for the majority of snakebite accidents recorded in Brazil.

Training was conducted over 60 epochs, with data augmentation via the **Albumentations** library and weighted sampling to mitigate class imbalance. In preliminary results, the model achieved **85.84% top-3 accuracy** and **70.03% top-1 accuracy**.

---

## 🛠️ Technologies Used

### Frontend
- **Framework**: Flutter
- **Language**: Dart

### Backend / AI
- **Language**: Python
- **API**: FastAPI
- **Deep Learning**: PyTorch
- **Classification architecture**: EfficientNet-B3 (transfer learning + fine-tuning)
- **Detection architecture**: YOLO *(planned for the next phase)*
- **Data augmentation**: Albumentations
- **Datasets**: SnakeCLEF, iNaturalist

### Infrastructure
- **Database / storage**: Supabase
- **Geolocation**: Google Maps Platform

---

## 👥 Technical Consulting

The project was supported by a researcher from **Instituto Butantan** to validate the practical relevance of the results.

---

## 📄 Scientific Paper

The full paper submitted to CONIC-SEMESP is available in this repository.