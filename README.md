# 🎬 **Poppi Cine**

Um aplicativo de streaming de filmes desenvolvido em **Flutter**, utilizando a API do **The Movie Database (TMDB)**. O **Poppi Cine** permite explorar filmes populares, lançamentos, programas de TV em alta e realizar buscas por seus títulos favoritos. Cada título conta com uma página de detalhes rica em informações como sinopse, elenco, trailers e muito mais.

> **Nota**: Este projeto utiliza a chave de API da TMDB. Substitua `''Minha API''` pela sua chave pessoal.

## ✨ Funcionalidades

- 🎥 **Banner rotativo de destaques**  
  Exibição dinâmica de filmes em destaque, atualizando automaticamente.

- 🆕 **Filmes mais recentes**  
  Descubra os lançamentos mais recentes no cinema.

- 🔥 **Títulos populares**  
  Lista dos filmes e séries mais populares no momento.

- 📺 **Séries em alta**  
  Explore programas de TV que estão em destaque.

- 🔍 **Busca inteligente**  
  Pesquise filmes e séries pelo título de forma rápida e precisa.

- 📝 **Página de detalhes**  
  Acesse informações completas: sinopse, elenco, diretor, trailers e outros metadados.

## 📂 Estrutura do Projeto

```bash
lib/
├── models/             # Modelos de dados
│   └── media_model.dart
│
├── providers/          # Gerenciamento de estado
│   └── media_provider.dart
│
├── screens/            # Telas da aplicação
│   ├── home_screen.dart
│   ├── details_screen.dart
│   └── search_screen.dart
│
├── services/           # Serviços e APIs
│   └── tmdb_service.dart
│
├── widgets/            # Componentes reutilizáveis
│   ├── media_card.dart
│   └── rotating_banner.dart
│
├── main.dart           # Ponto de entrada do app
├── theme.dart          # Definições de tema
└── image_util.dart     # Utilitário de imagens
```

## 🛠️ Bibliotecas e Dependências

As principais extensões e pacotes utilizados estão definidos no `pubspec.yaml`. Entre eles:

- **http** — Requisições HTTP à API TMDB
- **provider** — Gerenciamento de estado
- **carousel_slider** — Banner rotativo
- **cached_network_image** — Carregamento otimizado de imagens
- **flutter_dotenv** _(opcional, mas recomendado)_ — Gerenciamento seguro da chave da API

## 🚀 Como rodar o projeto

1. Clone o repositório:

```bash
git clone https://github.com/seu-usuario/poppi-cine.git
cd poppi-cine
```

## 📱 Compatibilidade

- ✅ **Android**
- ✅ **iOS**

## 📬 Contato

Se você tiver alguma dúvida ou sugestão, entre em contato:

- **Autor:** Guilherme Poppi
- **GitHub:** [Daischi](https://github.com/Daischi)
