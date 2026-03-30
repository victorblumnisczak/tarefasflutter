# CLAUDE.md — tarefa3 (Atividade CRUD - Dispositivos Móveis II)

## Visão Geral do Projeto

Aplicação Flutter acadêmica que consome a **FakeStoreAPI** (`https://fakestoreapi.com/products`) para gerenciar produtos. Projeto segue arquitetura em camadas (Clean Architecture simplificada) com MVVM na presentation layer, usando **Provider** + **ValueNotifier** para gerenciamento de estado.

**Objetivo atual:** Evoluir o app de somente-leitura (GET) para CRUD completo (GET + POST + PUT + DELETE), com formulários de cadastro/edição, exclusão com confirmação e atualização da interface após cada operação.

---

## Arquitetura Atual

```
lib/
├── main.dart                          # Entry point com DI manual via Provider
├── core/
│   ├── errors/
│   │   ├── app_errors.dart           # Exceções customizadas
│   │   └── failure.dart              # Classe Failure genérica
│   └── presentation/
│       └── app_root.dart             # MaterialApp + rotas + HomePage
└── features/
    ├── products/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── product_remote_datasource.dart  # HTTP com fakestoreapi.com
    │   │   │   └── product_cache_datasource.dart   # Cache em memória
    │   │   ├── models/
    │   │   │   └── product_model.dart              # DTO fromJson/toJson + toEntity
    │   │   └── repositories/
    │   │       └── product_repository_impl.dart    # Impl com fallback p/ cache
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── product.dart                    # Entidade de domínio
    │   │   └── repositories/
    │   │       └── product_repository.dart         # Interface abstrata
    │   └── presentation/
    │       ├── pages/
    │       │   ├── product_page.dart               # Tela de listagem
    │       │   └── product_detail_page.dart        # Tela de detalhes
    │       └── viewmodels/
    │           ├── product_viewmodel.dart           # Lógica de estado
    │           └── product_state.dart               # Estado imutável (copyWith)
    └── todos/                         # Feature separada (NÃO ALTERAR)
```

---

## Padrões em Uso

| Camada        | Padrão                  | Detalhes                                              |
|---------------|-------------------------|-------------------------------------------------------|
| Presentation  | MVVM + ValueNotifier    | `ProductViewModel` expõe `ValueNotifier<ProductState>` |
| Domain        | Repository Interface    | `ProductRepository` abstrata                           |
| Data          | Repository Impl + DTO   | `ProductRepositoryImpl` com remote + cache fallback    |
| DI            | Manual no `main.dart`   | Instanciação direta, injetado via `Provider`           |
| Navegação     | Navigator.push direto   | MaterialPageRoute com passagem por construtor          |

---

## Estado Atual (Após Atividade Anterior)

### O que já existe:
- ✅ `HomePage` com botão "Ver Produtos"
- ✅ `ProductPage` lista produtos da FakeStoreAPI (título, preço, imagem)
- ✅ `ProductDetailPage` exibe detalhes completos (description, category, rating)
- ✅ Navegação listagem → detalhes via `Navigator.push`
- ✅ Sistema de favoritos com toggle e filtro
- ✅ Loading indicator e tratamento de erro com retry
- ✅ Cache em memória como fallback
- ✅ Entity/Model com campos: id, title, price, image, description, category, rating, ratingCount

### O que falta (escopo desta atividade):
- ❌ Método `createProduct()` no service/datasource (POST)
- ❌ Método `updateProduct()` no service/datasource (PUT)
- ❌ Método `deleteProduct()` no service/datasource (DELETE)
- ❌ Métodos correspondentes no Repository (interface + impl)
- ❌ Métodos no ViewModel para create/update/delete
- ❌ `ProductFormPage` — tela de formulário para cadastro E edição (reutilizada)
- ❌ Botão de exclusão na tela de detalhes com diálogo de confirmação
- ❌ Botão FAB "+" na listagem para abrir cadastro
- ❌ Botão "Editar" na tela de detalhes
- ❌ Atualização da listagem após create/update/delete
- ❌ Método `toJson()` na Entity (necessário para POST/PUT)

---

## API Utilizada

**Base URL:** `https://fakestoreapi.com/products`

### Endpoints necessários:

| Operação | Método | URL                    | Body         | Resposta          |
|----------|--------|------------------------|--------------|-------------------|
| Listar   | GET    | `/products`            | —            | `List<Product>`   |
| Buscar   | GET    | `/products/{id}`       | —            | `Product`         |
| Criar    | POST   | `/products`            | JSON Product | `Product` com id  |
| Atualizar| PUT    | `/products/{id}`       | JSON Product | `Product`         |
| Remover  | DELETE | `/products/{id}`       | —            | `Product`         |

### JSON completo de um produto:
```json
{
  "id": 1,
  "title": "Fjallraven - Foldsack No. 1 Backpack",
  "price": 109.95,
  "description": "Your perfect pack for everyday use...",
  "category": "men's clothing",
  "image": "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg",
  "rating": { "rate": 3.9, "count": 120 }
}
```

### IMPORTANTE sobre a FakeStoreAPI:
- POST/PUT/DELETE **simulam** a operação e retornam resposta válida, mas **NÃO persistem** os dados no servidor
- Ou seja: um POST retorna o produto com id gerado, mas na próxima chamada GET ele não aparece
- Para a atividade isso é aceitável — o foco é demonstrar o fluxo CRUD funcional

---

## Regras e Convenções

### Obrigatório seguir:
1. **Manter a arquitetura em camadas existente** — não misturar responsabilidades
2. **Não alterar a feature `todos/`** — está fora do escopo
3. **Provider + ValueNotifier** — não introduzir Riverpod, Bloc, etc.
4. **Português** nos comentários e textos da UI
5. **Uma única `ProductFormPage`** reutilizada para cadastro E edição
6. **Confirmação antes de excluir** — usar `showDialog` com AlertDialog
7. **Atualizar a listagem** após qualquer operação de escrita (recarregar via GET ou atualizar estado local)
8. **Manter favoritos e filtro** funcionando — não quebrar funcionalidades existentes
9. **Validação de formulário** — usar `Form`, `GlobalKey<FormState>`, `TextFormField` com validators

### Estrutura de pastas para novos arquivos:
- Novas pages em `features/products/presentation/pages/`
- Novos métodos nos arquivos existentes de datasource, repository e viewmodel

---

## Dependências Atuais (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0        # Requisições HTTP
  provider: ^6.1.2    # DI e estado
```

### Dependências extras necessárias:
- Nenhuma extra obrigatória — `http` já suporta POST, PUT e DELETE

---

## Modelo de Produto — Campos para `toJson()`

O model já tem `fromJson` e `toEntity`. Precisa adicionar `toJson()` para enviar dados nos métodos POST e PUT:

```dart
Map<String, dynamic> toJson() {
  return {
    'title': title,
    'price': price,
    'description': description,
    'image': image,
    'category': category,
  };
}
```

**Notas:**
- `id` NÃO é incluído no toJson para POST (a API gera)
- `rating` NÃO é incluído (não faz sentido enviar rating no cadastro)
- Para PUT, o `id` vai na URL, não no body

---

## Fluxo de Telas Esperado

```
HomePage
  └─→ ProductPage (listagem)
        ├─→ ProductDetailPage (detalhes) — ao clicar num produto
        │     ├─→ ProductFormPage (edição) — botão "Editar"
        │     └─→ [Excluir com confirmação] — botão lixeira
        └─→ ProductFormPage (cadastro) — FAB "+"
```

### Navegação e retorno:
- Cadastro/Edição: `Navigator.push` → ao salvar com sucesso, `Navigator.pop(context, true)`
- Exclusão: após confirmar e excluir, `Navigator.pop(context, true)`
- Na tela que chamou: verificar `result == true` e recarregar dados

---

## Plano de Implementação (Ordem Recomendada)

### Passo 1: Adicionar toJson na Entity/Model
- `Product` entity: adicionar método `toJson()`
- `ProductModel`: adicionar método `toJson()` (pode delegar pro entity ou ter próprio)

### Passo 2: Expandir o Remote DataSource
- Adicionar `createProduct(Product product)` → `http.post`
- Adicionar `updateProduct(Product product)` → `http.put`
- Adicionar `deleteProduct(int id)` → `http.delete`

### Passo 3: Expandir o Repository
- Interface: adicionar assinaturas `createProduct`, `updateProduct`, `deleteProduct`
- Impl: implementar chamando o remote datasource

### Passo 4: Expandir o ViewModel
- Adicionar métodos `createProduct`, `updateProduct`, `deleteProduct`
- Cada método deve: executar a operação → recarregar a lista (chamar `loadProducts()` novamente)
- Gerenciar estado de loading durante operações

### Passo 5: Criar ProductFormPage
- StatefulWidget com Form
- Recebe `Product?` opcional pelo construtor (null = cadastro, preenchido = edição)
- Campos: título, preço, descrição, imagem (URL), categoria
- TextEditingController para cada campo, inicializados com dados do produto se for edição
- Validação em cada campo
- Botão "Salvar" que chama create ou update no ViewModel
- Loading state no botão durante operação
- SnackBar de sucesso/erro
- `Navigator.pop(context, true)` ao concluir

### Passo 6: Adicionar ações na tela de detalhes
- Botão "Editar" → abre ProductFormPage com o produto
- Botão lixeira no AppBar → showDialog de confirmação → delete → pop com true

### Passo 7: Adicionar FAB na listagem
- FloatingActionButton com ícone "+" na ProductPage
- Ao clicar, abre ProductFormPage sem produto (modo cadastro)
- Ao retornar com `true`, recarrega a listagem

### Passo 8: Atualização da interface
- Garantir que após create/update/delete a listagem reflita as mudanças
- Opção 1: chamar `loadProducts()` no ViewModel (refaz GET)
- Opção 2: atualizar lista local no state (mais responsivo, mas a API fake não persiste)
- Recomendado: Opção 1 por simplicidade, já que a FakeStoreAPI não persiste mesmo