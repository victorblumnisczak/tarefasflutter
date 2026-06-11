# CONTEXT.md — Estado Atual do Projeto

> Este arquivo descreve **onde o projeto está agora** e o que **NÃO deve ser tocado**. Para a especificação do que deve ser feito, ver `CLAUDE.md`. Para o passo-a-passo de execução, ver `PROMPT_CLAUDE_CODE.md`.

---

## Snapshot do Projeto

**Nome do projeto Flutter:** `todo_refatoracao_baguncado` (mantido por compatibilidade com tarefas anteriores).

**Última tarefa concluída:** Refatoração de Clean Architecture → arquitetura simplificada (`models/`, `services/`, `screens/`, `widgets/`). O resultado dessa refatoração é o que está no zip atual.

**Tarefa em andamento:** Implementar **autenticação com DummyJSON** e **substituir a FakeStoreAPI pela DummyJSON** na listagem de produtos.

---

## Estrutura Atual de `lib/`

```
lib/
├── main.dart                              # entry point — abre HomeScreen
├── models/
│   └── product.dart                       # modelo da FakeStoreAPI (id, title, price, image, …)
├── services/
│   └── product_service.dart               # CRUD na FakeStoreAPI (GET/POST/PUT/DELETE)
├── screens/
│   ├── home_screen.dart                   # tela inicial com botão "Ver Produtos"
│   ├── product_list_screen.dart           # listagem com FAB de cadastro
│   ├── product_detail_screen.dart         # detalhes + editar/excluir
│   └── product_form_screen.dart           # formulário (cadastro/edição)
├── widgets/
│   └── product_card.dart                  # card usado na listagem
└── features/
    └── todos/                             # feature isolada — Clean Architecture
        ├── data/
        ├── domain/
        └── presentation/
```

**Convenção de nomenclatura usada:** pasta `screens/` com sufixo `_screen.dart`. **Manter** essa convenção — a aula sugere `pages/` mas é apenas exemplo; o que importa é a separação de responsabilidades.

---

## API Atualmente Consumida

**FakeStoreAPI** — `https://fakestoreapi.com/products`

Resposta de listagem é um **array direto** (sem envelope):
```json
[
  {
    "id": 1,
    "title": "...",
    "price": 109.95,
    "image": "https://...",
    "rating": { "rate": 3.9, "count": 120 }
  }
]
```

CRUD funciona (POST/PUT/DELETE) mas a API **simula** sem persistir — os produtos criados não aparecem no GET seguinte. Isso é esperado.

---

## O Que Vai Sair de Cena

A nova tarefa exige **substituir** a FakeStoreAPI pela DummyJSON e **só listar/detalhar** produtos (sem CRUD de produtos). Portanto:

| Item                                  | Destino                                |
|---------------------------------------|----------------------------------------|
| `screens/home_screen.dart`            | **DELETAR** — login passa a ser a entrada |
| `screens/product_form_screen.dart`    | **DELETAR** — sem cadastro/edição agora |
| `addProduct` / `updateProduct` / `deleteProduct` em `ProductService` | **REMOVER** — fora do escopo |
| Botão de excluir na `ProductDetailScreen` | **REMOVER** |
| Botão "Editar" na `ProductDetailScreen` | **REMOVER** |
| FAB "+" na `ProductListScreen`        | **REMOVER** |

Tudo isso era do mundo da FakeStoreAPI. Sai junto.

---

## O Que NÃO Pode Ser Tocado

1. **`features/todos/`** — feature isolada, fora do escopo desta tarefa. Continua funcionando com Provider + Clean Architecture. Nem imports, nem rotas, nem `main.dart` no que se refere ao Provider do `TodoViewModel`.
2. **`pubspec.yaml`** — todas as dependências atuais (`http`, `provider`, `shared_preferences`, `cupertino_icons`) já cobrem o necessário. **Não adicionar pacote novo.**
3. **Pastas de plataforma** (`android/`, `ios/`, `web/`, etc.) — sem alterações.
4. **Registro do `TodoViewModel` no `main.dart`** — mantém o `MultiProvider` e a rota `/todos`.

---

## Dependências Disponíveis (já no `pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  http: ^1.2.2                # POST/GET para auth e produtos
  provider: ^6.1.2            # mantido só pelo TodoViewModel
  shared_preferences: ^2.3.2  # disponível para persistir token (extra)
```

`shared_preferences` já está no projeto por causa da feature `todos/`. Pode ser usado **de graça** para o desafio extra de persistência de token, sem mexer no `pubspec`.

---

## Credenciais de Teste (DummyJSON)

```
usuário: emilys
senha:   emilyspass
```

A API responde em `https://dummyjson.com/auth/login` com `accessToken`, `refreshToken`, e dados do usuário (`id`, `username`, `email`, `firstName`, `lastName`, `image`).

---

## Convenções do Projeto

- **Idioma:** UI e mensagens de erro em português; nomes de classes/variáveis em inglês.
- **Estado:** `setState` nas telas de produtos (sem Provider/ViewModel para essa parte). Provider continua **só** para `TodoViewModel`.
- **HTTP:** pacote `http` direto, sem wrapper (a aula não pede).
- **Async:** `try/catch/finally` com tratamento de `mounted` antes de tocar em `context`.
- **Navegação:** `Navigator.push` e `Navigator.pushReplacement` (nada de rotas nomeadas para o fluxo novo, só a `/todos` que já existe).
- **Imports relativos** dentro de `lib/`.

---

## Como Continuar

1. Ler `CLAUDE.md` para entender a arquitetura alvo (modelos, services, session, telas).
2. Seguir `PROMPT_CLAUDE_CODE.md` passo-a-passo para a execução.
3. Ao final, validar com o checklist no fim do `CLAUDE.md`.
