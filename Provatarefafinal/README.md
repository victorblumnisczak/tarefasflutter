# mobile_arquitetura_01

Aplicação Flutter da atividade final de Dispositivos Móveis II. O app consome a API **DummyJSON** (`https://dummyjson.com`) e entrega autenticação com sessão persistida, listagem e detalhe de produtos, perfil do usuário e **controle de favoritos** com atualização automática da interface.

## Como rodar

```bash
flutter pub get
flutter run
```

## Credenciais de teste

```
Usuário: emilys
Senha:   emilyspass
```

## Gerência de estado

O app usa **duas estratégias de estado, cada uma onde faz sentido**. Fluxos lineares e sem estado compartilhado vivo (login, carregamento de produtos, detalhe, perfil) usam **`setState`**, por simplicidade e localidade. O **controle de favoritos** usa **`Provider` + `ChangeNotifier`** (`FavoritesController`), porque o mesmo estado é observado por três telas (lista, detalhe e favoritos) e precisa de **atualização automática** assim que o usuário marca/desmarca — um estado reativo central evita sincronização manual entre telas. A feature `todos/` mantém seu próprio `Provider`, já existente. Essa coexistência é intencional.

Os favoritos são persistidos em `shared_preferences` (apenas os IDs, chave `favorite_ids`), então sobrevivem ao fechamento do app — assim como a sessão do usuário (chave `auth_user`).

## Como os requisitos foram atendidos

### Autenticação e sessão
- `LoginScreen` com validação obrigatória de usuário e senha; POST em `/auth/login` via `AuthService`; erro de credenciais exibido em `SnackBar`.
- `SessionController` (singleton em `lib/session/`) guarda o usuário em memória e persiste o token em `shared_preferences`; `SplashScreen` restaura a sessão e bloqueia o acesso sem login.
- AppBar da lista mostra o nome e o avatar do usuário (toque abre o perfil via `/auth/me`) e tem botão de logout.

### Produtos
- `ProductService` consome `GET /products` (lendo o envelope `data['products']`) e `GET /products/{id}`.
- `Product` segue a estrutura da DummyJSON (`thumbnail`, `rating` plano, `stock`).
- Lista com `ProductCard` (imagem, título, preço) e tela de detalhe com imagem, nome, categoria, preço, rating, estoque e descrição.

### Favoritos
- `FavoritesController` (`lib/controllers/`) — `ChangeNotifier` com `toggle`, `isFavorite`, `ids`, `count`, `load` e persistência em `shared_preferences`.
- Marcar/remover favorito pelo coração no card da lista, no detalhe e na `FavoritesScreen`; como as três telas observam o mesmo controller, a UI atualiza sozinha em todas elas.
- `FavoritesScreen` trata carregamento, erro (com "Tentar novamente") e lista vazia.

### Navegação
- `Navigator.push` para detalhe, perfil e favoritos; `pushReplacement` nas transições de fluxo (splash → login/lista, login → lista, logout → login).
- `Navigator.pop` explícito no botão **"Voltar à lista"** da tela de detalhe.

### Arquitetura e robustez
- Camadas separadas: `models/`, `services/`, `session/`, `controllers/`, `screens/`, `widgets/`; a feature `features/todos/` permanece isolada com seu próprio Provider (ver `ARCH.md`).
- Todas as requisições tratam carregamento (loaders) e erro (mensagem + retry/SnackBar).
