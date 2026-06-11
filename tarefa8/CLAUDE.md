# CLAUDE.md — Autenticação Mobile com DummyJSON (Dispositivos Móveis II)

## Visão Geral

Aplicação Flutter acadêmica que **deixa de consumir** a FakeStoreAPI e passa a consumir a **DummyJSON** (`https://dummyjson.com`). Além da troca de API, o projeto ganha um **fluxo de autenticação completo**: o usuário só acessa a listagem de produtos depois de fazer login. A sessão é mantida em memória durante a execução do app, com possibilidade de persistir o token via `shared_preferences` (desafio extra).

A feature `features/todos/` continua intocada — não faz parte desta tarefa.

---

## Estado Anterior (para contexto)

```
HomeScreen → ProductListScreen → ProductDetailScreen
                              ↓
                       ProductFormScreen (cadastro/edição)
```

API: FakeStoreAPI. CRUD funcionando.

## Estado Alvo

```
SplashScreen (verifica sessão)
  ├─→ LoginScreen (sem sessão)
  │      └─→ ProductListScreen (após login bem-sucedido)
  │             └─→ ProductDetailScreen (toque em produto)
  └─→ ProductListScreen (com sessão ativa)
```

API: DummyJSON. Sem CRUD de produtos.

---

## Estrutura Alvo de `lib/`

```
lib/
├── main.dart                          # entry → SplashScreen, mantém Provider do TodoVM
├── models/
│   ├── auth_user.dart                 # NOVO — usuário autenticado
│   └── product.dart                   # AJUSTADO — DummyJSON (thumbnail, rating flat)
├── services/
│   ├── auth_service.dart              # NOVO — POST /auth/login, GET /auth/me
│   └── product_service.dart           # AJUSTADO — DummyJSON, sem CRUD
├── session/
│   └── session_controller.dart        # NOVO — singleton em memória + token persistido
├── screens/
│   ├── splash_screen.dart             # NOVO — extra: verifica sessão e roteia
│   ├── login_screen.dart              # NOVO
│   ├── product_list_screen.dart       # AJUSTADO — sem FAB, com logout no AppBar
│   └── product_detail_screen.dart     # AJUSTADO — busca por id, sem editar/excluir
├── widgets/
│   └── product_card.dart              # AJUSTADO — thumbnail no lugar de image
└── features/
    └── todos/                         # NÃO MEXER
```

### Arquivos a deletar
- `lib/screens/home_screen.dart` — login vira a entrada
- `lib/screens/product_form_screen.dart` — sem CRUD de produtos

---

## Mapeamento (Antes → Depois)

| Antes                              | Depois                                  | Ação                                  |
|------------------------------------|-----------------------------------------|---------------------------------------|
| `screens/home_screen.dart`         | (removido)                              | DELETAR                               |
| `screens/product_form_screen.dart` | (removido)                              | DELETAR                               |
| `models/product.dart` (FakeStore)  | `models/product.dart` (DummyJSON)       | AJUSTAR — `image`→`thumbnail`, rating flat |
| `services/product_service.dart`    | `services/product_service.dart` (DummyJSON) | AJUSTAR — só `fetchProducts` e `fetchProductById`; troca da `_baseUrl`; ler `data['products']` |
| `widgets/product_card.dart`        | `widgets/product_card.dart`             | AJUSTAR — `product.thumbnail`         |
| `screens/product_list_screen.dart` | `screens/product_list_screen.dart`      | AJUSTAR — remove FAB, adiciona logout, mostra nome do usuário no AppBar |
| `screens/product_detail_screen.dart` | `screens/product_detail_screen.dart`  | AJUSTAR — recebe `productId` (int) e busca via `fetchProductById`; remove botões editar/excluir |
| `main.dart`                        | `main.dart`                             | AJUSTAR — `home: SplashScreen()`, mantém `MultiProvider` do `TodoViewModel` |
| —                                  | `models/auth_user.dart`                 | CRIAR                                 |
| —                                  | `services/auth_service.dart`            | CRIAR                                 |
| —                                  | `session/session_controller.dart`       | CRIAR                                 |
| —                                  | `screens/login_screen.dart`             | CRIAR                                 |
| —                                  | `screens/splash_screen.dart`            | CRIAR (extra)                         |

---

## API DummyJSON

**Base:** `https://dummyjson.com`

| Operação            | Método | URL              | Body                                          | Resposta principal                                    |
|---------------------|--------|------------------|-----------------------------------------------|-------------------------------------------------------|
| Login               | POST   | `/auth/login`    | `{ username, password, expiresInMins: 30 }`   | `{ id, username, email, firstName, lastName, image, accessToken, refreshToken }` |
| Perfil              | GET    | `/auth/me`       | header `Authorization: Bearer <accessToken>`  | objeto do usuário                                     |
| Listar produtos     | GET    | `/products`      | —                                             | `{ products: [...], total, skip, limit }`             |
| Detalhe de produto  | GET    | `/products/{id}` | —                                             | objeto do produto                                     |

**Diferenças críticas em relação à FakeStoreAPI:**
1. Listagem retorna **objeto envelope** (`data['products']`), não array direto.
2. Imagem do produto está em **`thumbnail`**, não em `image`.
3. `rating` é um **número plano** (double), não `{ rate, count }`.
4. Login retorna `accessToken` que pode ser usado em `Authorization: Bearer …`.

---

## Modelos

### `models/auth_user.dart` — NOVO

Campos: `id` (int), `username`, `email`, `firstName`, `lastName`, `image` (URL do avatar), `accessToken`, `refreshToken`.

Métodos:
- `factory AuthUser.fromJson(Map<String, dynamic> json)`
- `String get fullName => '$firstName $lastName';`
- `Map<String, dynamic> toJson()` — útil para persistir em `shared_preferences`
- `factory AuthUser.fromStoredJson(Map<String, dynamic> json)` — reconstrói a partir do storage (mesma lógica do `fromJson`)

### `models/product.dart` — AJUSTADO

Campos novos: `id` (int), `title`, `description`, `category`, `price` (double), `rating` (double), `stock` (int), `thumbnail` (URL).

`fromJson` deve usar `(json['price'] as num).toDouble()` e `(json['rating'] as num).toDouble()` para tolerar int/double do JSON.

**Remover:** o `toJson()` antigo voltado a POST/PUT (não tem mais CRUD).

---

## Services

### `services/auth_service.dart` — NOVO

```
final String baseUrl = 'https://dummyjson.com/auth';

Future<AuthUser> login({ required String username, required String password })
Future<Map<String, dynamic>> getCurrentUser(String accessToken)   // /auth/me
```

- `login` envia POST com `Content-Type: application/json` e body `{ username, password, expiresInMins: 30 }`. Em sucesso (200), retorna `AuthUser.fromJson(jsonDecode(body))`. Em erro, lança `Exception('Usuário ou senha inválidos')`.
- `getCurrentUser` faz GET em `/auth/me` com `Authorization: Bearer <token>`. Usado para reavaliar a sessão na splash.

### `services/product_service.dart` — AJUSTADO

```
final String _baseUrl = 'https://dummyjson.com/products';

Future<List<Product>> fetchProducts()
Future<Product> fetchProductById(int id)
```

- `fetchProducts` faz GET em `/products`, decodifica como `Map<String, dynamic>`, lê `data['products']` como `List<dynamic>` e mapeia.
- `fetchProductById` faz GET em `/products/{id}` e decodifica direto como objeto.
- **Remover** `addProduct`, `updateProduct`, `deleteProduct`.

---

## Sessão

### `session/session_controller.dart` — NOVO

Singleton em memória + persistência opcional do token via `shared_preferences`.

**API mínima:**
- `static SessionController get instance` — singleton
- `AuthUser? get user`
- `String? get token`
- `bool get isLoggedIn`
- `Future<void> login(AuthUser user)` — guarda em memória **e** persiste em `shared_preferences`
- `Future<void> logout()` — limpa memória **e** storage
- `Future<bool> tryRestore()` — tenta reidratar a partir do `shared_preferences`. Retorna `true` se restaurou.

**Chave do storage:** `'auth_user'` armazenando o JSON do `AuthUser` (string).

> Em memória: `_user` é a fonte da verdade durante a sessão. O `shared_preferences` é só backup para sobreviver ao fechamento do app.

---

## Telas

### 1. `screens/splash_screen.dart` — NOVO (extra: auto-login)

- `StatefulWidget`. No `initState`, chama `SessionController.instance.tryRestore()`.
- Mostra `CircularProgressIndicator` centralizado enquanto verifica.
- Se restaurou sessão → `Navigator.pushReplacement` para `ProductListScreen`.
- Se não → `Navigator.pushReplacement` para `LoginScreen`.

### 2. `screens/login_screen.dart` — NOVO

- `StatefulWidget` com `_formKey = GlobalKey<FormState>()`.
- `TextEditingController` para `username` e `password` (já preenchidos com `emilys` / `emilyspass` para facilitar testes — comentar que é demonstrativo).
- Estado: `_isLoading`, `_obscurePassword`.
- Validators: ambos os campos obrigatórios.
- Botão "Entrar" → valida → chama `AuthService.login(...)` → `SessionController.instance.login(user)` → `Navigator.pushReplacement` para `ProductListScreen`.
- Em erro: `SnackBar` com "Usuário ou senha inválidos".
- `dispose` libera os controllers.

### 3. `screens/product_list_screen.dart` — AJUSTADO

- Mantém `setState` e o `Future<List<Product>>?` no estado.
- AppBar:
  - Title: `'Produtos'`.
  - **Adicionar** (extra) `CircleAvatar` com `NetworkImage(user.image)` à esquerda do nome do usuário.
  - Texto com `user.firstName` (ex.: "Olá, Emily").
  - **Botão refresh** (já existe) — mantém.
  - **Botão logout** (`Icons.logout`) → `SessionController.instance.logout()` + `Navigator.pushReplacement` para `LoginScreen`.
- **Remover** o `FloatingActionButton` de cadastro.
- O `onTap` do `ProductCard` agora navega passando **apenas o `product.id`** (não o produto inteiro), porque a tela de detalhes vai buscar pela API.
- Tratamento de loading/erro/vazio mantido.

### 4. `screens/product_detail_screen.dart` — AJUSTADO

- `StatelessWidget` com `final int productId` no construtor.
- Usa `FutureBuilder<Product>` chamando `ProductService().fetchProductById(productId)`.
- Layout: imagem (`product.thumbnail`), título, categoria, preço, rating, estoque, descrição.
- **Remover** botões "Editar" e "Excluir" do AppBar.
- **Remover** método `_confirmarExclusao`.

---

## Widgets

### `widgets/product_card.dart` — AJUSTADO

- Trocar `product.image` por `product.thumbnail` no `Image.network`.
- Resto do layout (ListTile com leading/title/subtitle/trailing) permanece.
- O `onTap` continua um callback do pai (que agora abre detalhes via `productId`).

---

## `main.dart`

- `home: const SplashScreen()`.
- Mantém `MultiProvider` com `TodoViewModel`.
- Mantém rota `/todos`.
- Remove import de `screens/home_screen.dart`.

---

## Fluxo de Navegação

```
SplashScreen
   │
   │ tryRestore() == true?
   │
   ├── sim → pushReplacement → ProductListScreen
   │                                  │
   │                                  ├── tap em card → push → ProductDetailScreen(productId)
   │                                  │                              └── pop → volta
   │                                  │
   │                                  └── tap em logout → SessionController.logout() + pushReplacement → LoginScreen
   │
   └── não → pushReplacement → LoginScreen
                                  │
                                  └── login OK → SessionController.login(user) + pushReplacement → ProductListScreen
```

`pushReplacement` em todos os pulos de fluxo (splash → next, login → produtos, logout → login) para evitar pilha indevida e botão "voltar" quebrando o fluxo.

---

## Desafios Extras Implementados

A atividade exige **pelo menos um** extra. Este projeto entrega três que se reforçam:

1. **Persistência do token com `shared_preferences`** (extra #1) — `SessionController.login` salva, `logout` apaga, `tryRestore` lê.
2. **Tela inicial que verifica sessão ativa** (extra #4) — `SplashScreen` decide o destino.
3. **Imagem do usuário autenticado no AppBar** (extra #3) — `CircleAvatar` na `ProductListScreen`.

> Observação: o desafio #6 ("botão para atualizar manualmente a lista de produtos") **já está implementado** no projeto base (ícone refresh no AppBar) e deve ser mantido.

---

## Regras e Convenções

1. **NÃO alterar `features/todos/`** — fora do escopo.
2. **NÃO adicionar dependências novas** — `http`, `provider`, `shared_preferences` já cobrem.
3. **`setState` para o estado de auth/produtos** — sem Provider/ValueNotifier nessa parte.
4. **Singleton do `SessionController`** com construtor privado e instância estática.
5. **`pushReplacement`** nas transições de fluxo (splash, login, logout).
6. **`Authorization: Bearer <token>`** quando precisar de rota protegida (nesta tarefa: só `/auth/me` na splash, opcionalmente).
7. **Português** em mensagens de UI e SnackBars.
8. **Tratamento de erro** em todas as chamadas HTTP, com `SnackBar` informativo.
9. **`mounted` checks** antes de tocar em `context` após `await`.
10. **Imports limpos** — sem referências aos arquivos deletados (`home_screen.dart`, `product_form_screen.dart`).

---

## Checklist de Validação

Ao finalizar, confirmar:

### Compilação e estrutura
- [ ] `flutter analyze` sem erros nem warnings.
- [ ] `flutter pub get` sem precisar instalar nada novo.
- [ ] Pastas: `models/`, `services/`, `session/`, `screens/`, `widgets/` em `lib/`.
- [ ] Arquivos deletados: `home_screen.dart`, `product_form_screen.dart`.
- [ ] Feature `features/todos/` intocada.

### Requisitos obrigatórios
- [ ] `SplashScreen` é a entrada do app.
- [ ] `LoginScreen` com campos usuário e senha + validação obrigatória.
- [ ] POST para `https://dummyjson.com/auth/login`.
- [ ] Erro de credenciais inválidas mostra SnackBar.
- [ ] `SessionController` armazena `AuthUser` autenticado.
- [ ] Após login → `pushReplacement` para `ProductListScreen`.
- [ ] Botão de logout no AppBar da `ProductListScreen`.
- [ ] Listagem via `https://dummyjson.com/products`.
- [ ] Tela de detalhes via `https://dummyjson.com/products/{id}`.
- [ ] `Product` ajustado para a estrutura DummyJSON.
- [ ] Separação `models/` ↔ `services/` ↔ `session/` ↔ `screens/`.

### Desafios extras
- [ ] Token persistido em `shared_preferences`.
- [ ] Splash verifica sessão e roteia.
- [ ] `CircleAvatar` com `user.image` no AppBar.

### Comportamento
- [ ] Fechar e reabrir o app: usuário continua logado (sessão restaurada).
- [ ] Logout limpa o `shared_preferences` e volta para login.
- [ ] Botão "voltar" do dispositivo na `ProductListScreen` não abre o login.
- [ ] Lista mostra `thumbnail` (e não erro de rede de imagem).
- [ ] Detalhes carregam via `productId` (não recebem o produto inteiro).
- [ ] Feature `todos/` continua acessível e funcional.

---

## Credenciais de Teste

```
Usuário: emilys
Senha:   emilyspass
```
