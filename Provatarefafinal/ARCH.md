
```
lib/
├── main.dart                                      # Entry point com DI
│
├── core/                                          # Recursos compartilhados
│   ├── errors/
│   │   └── app_errors.dart                       # Exceções customizadas
│   └── presentation/
│       └── app_root.dart                         # Widget raiz (MaterialApp)
│
└── features/                                      # Features do app (feature-first)
    └── todos/                                     # Feature de TODOs
        ├── data/                                  # Camada de dados
        │   ├── datasources/
        │   │   ├── todo_local_datasource.dart    # Persistência local (SharedPreferences)
        │   │   └── todo_remote_datasource.dart   # API HTTP (JSONPlaceholder)
        │   ├── models/
        │   │   └── todo_model.dart               # DTO com fromJson/toJson
        │   └── repositories/
        │       └── todo_repository_impl.dart     # Implementação do repository
        │
        ├── domain/                                # Camada de domínio (regras de negócio)
        │   ├── entities/
        │   │   └── todo.dart                     # Entidade de domínio (Todo)
        │   └── repositories/
        │       └── todo_repository.dart          # Interface do repository
        │
        └── presentation/                          # Camada de apresentação (UI)
            ├── pages/
            │   └── todos_page.dart               # Tela principal de TODOs
            ├── viewmodels/
            │   └── todo_viewmodel.dart           # Gerenciamento de estado
            └── widgets/
                └── add_todo_dialog.dart          # Dialog para adicionar TODO
```

---

```
┌──────────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                            │
│  ┌────────────┐      ┌──────────────┐      ┌─────────────────────┐  │
│  │ TodosPage  │ ───> │ TodoViewModel│ ───> │ TodoRepository      │  │
│  │ (UI)       │      │ (Estado)     │      │ (Interface/Contrato)│  │
│  └────────────┘      └──────────────┘      └─────────────────────┘  │
└──────────────────────────────────────────────────────────────────────┘
                                 │
                                 │ depende de (interface)
                                 ▼
┌──────────────────────────────────────────────────────────────────────┐
│                           DOMAIN LAYER                                │
│                     ┌─────────────────────┐                          │
│                     │ TodoRepository      │ (Abstract class)         │
│                     │ - fetchTodos()      │                          │
│                     │ - addTodo()         │                          │
│                     │ - updateCompleted() │                          │
│                     └─────────────────────┘                          │
│                              ▲                                        │
│                              │ implementa                             │
└──────────────────────────────┼──────────────────────────────────────┘
                               │
┌──────────────────────────────┼──────────────────────────────────────┐
│                         DATA LAYER                                    │
│                  ┌───────────────────────┐                           │
│                  │ TodoRepositoryImpl    │                           │
│                  │ (Implementação)       │                           │
│                  └───────────────────────┘                           │
│                    │                   │                             │
│        ┌───────────┘                   └──────────┐                  │
│        ▼                                          ▼                  │
│  ┌──────────────────────┐            ┌──────────────────────────┐   │
│  │ TodoRemoteDataSource │            │ TodoLocalDataSource      │   │
│  │ (HTTP/API)           │            │ (SharedPreferences)      │   │
│  │ - fetchTodos()       │            │ - saveLastSync()         │   │
│  │ - addTodo()          │            │ - getLastSync()          │   │
│  │ - updateCompleted()  │            └──────────────────────────┘   │
│  └──────────────────────┘                                            │
│          │                                                            │
│          ▼                                                            │
│  ┌──────────────────────┐                                            │
│  │ TodoModel            │ (DTO com JSON)                             │
│  │ - fromJson()         │                                            │
│  │ - toJson()           │                                            │
│  └──────────────────────┘                                            │
└──────────────────────────────────────────────────────────────────────┘
```

### Legenda do Fluxo:
- **UI → ViewModel → Repository (interface) → RepositoryImpl → DataSources**
- A UI nunca chama HTTP ou SharedPreferences diretamente 
- O ViewModel depende da **interface** (TodoRepository), não da implementação
- A injeção de dependência acontece no **main.dart**

---

### 1. **Onde ficou a validação?**

**Resposta:** No **ViewModel** (camada de apresentação).

**Justificativa:**
- Validações de entrada do usuário (ex: campo vazio) ficam no **TodoViewModel**
- Exemplo: método `addTodo()` valida se `title.trim().isEmpty` antes de chamar o repository
- Validações de negócio complexas poderiam ficar em use cases (não aplicável neste projeto simples)

**Localização:**
- `lib/features/todos/presentation/viewmodels/todo_viewmodel.dart:36`

```dart
if (title.trim().isEmpty) {
  errorMessage = 'Título não pode ser vazio.';
  notifyListeners();
  return;
}
```

---

### 2. **Onde ficou o parsing JSON?**

**Resposta:** No **TodoModel** (camada de dados).

**Justificativa:**
- O parsing JSON é responsabilidade da **camada de dados**, pois é um detalhe de implementação
- **TodoModel** (DTO) possui `fromJson()` e `toJson()` para serialização
- A **entidade de domínio** (Todo) não conhece JSON, mantendo-se pura
- O **TodoRemoteDataSource** usa TodoModel.fromJson() para converter respostas da API

**Localização:**
- `lib/features/todos/data/models/todo_model.dart:10-16` (fromJson)
- `lib/features/todos/data/models/todo_model.dart:18-22` (toJson)

```dart
factory TodoModel.fromJson(Map<String, dynamic> json) {
  return TodoModel(
    id: (json['id'] as num).toInt(),
    title: (json['title'] ?? '').toString(),
    completed: (json['completed'] ?? false) as bool,
  );
}
```

---

### 3. **Como você tratou erros?**

**Resposta:** Com **try-catch** nas camadas apropriadas e **AppError** customizado.

**Justificativa:**
- **TodoRemoteDataSource** lança `Exception` quando status HTTP está fora do range 200-299
- **TodoViewModel** captura exceções em `try-catch` e armazena mensagem legível no `errorMessage`
- **AppError** (em `core/errors/`) pode ser usado para exceções customizadas do domínio
- A **UI** (TodosPage) exibe `errorMessage` para o usuário quando `vm.errorMessage != null`
- **Rollback otimista**: ao atualizar checkbox, se falhar, reverte o estado anterior

**Localização:**
- Lançamento de erros: `lib/features/todos/data/datasources/todo_remote_datasource.dart:14-16`
- Tratamento no ViewModel: `lib/features/todos/presentation/viewmodels/todo_viewmodel.dart:26-27`
- Rollback otimista: `lib/features/todos/presentation/viewmodels/todo_viewmodel.dart:61-65`
- Exibição na UI: `lib/features/todos/presentation/pages/todos_page.dart:58-74`

```dart
// Data Source lança exception
if (res.statusCode < 200 || res.statusCode >= 300) {
  throw Exception('HTTP ${res.statusCode}');
}

// ViewModel captura e armazena mensagem
try {
  final result = await _repo.fetchTodos(forceRefresh: forceRefresh);
  // ...
} catch (e) {
  errorMessage = 'Falha ao carregar: $e';
}

// UI exibe para o usuário
if (vm.errorMessage != null && vm.items.isEmpty) {
  return Center(child: Text(vm.errorMessage!));
}
```

---

## Padrões e Princípios Aplicados

### 1. **Clean Architecture**
- Separação clara entre **Domain**, **Data** e **Presentation**
- Dependências apontam para dentro (regra de dependência)
- Domain não conhece detalhes de implementação (HTTP, SharedPreferences, Flutter)

### 2. **Feature-First Organization**
- Código organizado por **features** (todos), não por tipo técnico
- Facilita escalabilidade: novas features podem ser adicionadas independentemente

### 3. **Dependency Inversion Principle (DIP)**
- **TodoViewModel** depende da **abstração** (TodoRepository), não da implementação
- Injeção de dependência acontece no `main.dart`
- Facilita testes: podemos injetar um mock do repository

### 4. **Repository Pattern**
- **TodoRepositoryImpl** centraliza acesso a dados remotos e locais
- Decide qual fonte usar (remoto/local) sem que o ViewModel precise saber
- Converte **TodoModel** (DTO) para **Todo** (entidade)

### 5. **Single Responsibility Principle (SRP)**
- Cada classe tem uma única responsabilidade:
  - **TodoRemoteDataSource**: apenas chamadas HTTP
  - **TodoLocalDataSource**: apenas persistência local
  - **TodoRepositoryImpl**: coordena data sources
  - **TodoViewModel**: gerencia estado da UI
  - **TodosPage**: renderiza UI

---

##  Responsabilidades das Camadas

### **Core** (Recursos Compartilhados)
- `core/errors/`: exceções customizadas usadas em todo o app
- `core/presentation/`: widgets raiz compartilhados (MaterialApp, tema)

### **Domain** (Regras de Negócio)
- `domain/entities/`: entidades de domínio puras (sem dependências externas)
- `domain/repositories/`: interfaces/contratos que a camada de dados implementa

### **Data** (Acesso a Dados)
- `data/datasources/`: fontes de dados concretas (API, banco, cache)
- `data/models/`: DTOs com lógica de serialização (JSON)
- `data/repositories/`: implementações dos contratos de domínio

### **Presentation** (Interface com Usuário)
- `presentation/pages/`: telas completas
- `presentation/viewmodels/`: gerenciamento de estado (ChangeNotifier)
- `presentation/widgets/`: widgets reutilizáveis

---

 **A UI não pode chamar HTTP nem SharedPreferences diretamente**
   - TodosPage usa apenas TodoViewModel ✓

 **O ViewModel não pode conhecer Widgets / BuildContext**
   - TodoViewModel importa apenas `foundation.dart` (ChangeNotifier) ✓
   - Não importa `material.dart` ou widgets específicos ✓

 **O Repository deve centralizar a escolha entre remoto/local**
   - TodoRepositoryImpl coordena ambos data sources ✓
   - Busca remoto, salva timestamp local, retorna última sincronização ✓

 **Injeção de Dependência**
   - TodoViewModel recebe TodoRepository via construtor ✓
   - main.dart instancia TodoRepositoryImpl e passa para o ViewModel ✓

---


```bash
# 1. Instalar dependências
flutter pub get

# 2. Rodar o app
flutter run

# 3. (Opcional) Analisar código
flutter analyze

# 4. (Opcional) Rodar testes
flutter test
```

---

##  Mudanças em Relação ao Projeto Original

### Antes (Projeto Desorganizado):
```
lib/
├── models/           # ❌ Misturado
├── repositories/     # ❌ Sem separação clara
├── screens/          # ❌ DataSource em screens!
├── services/         # ❌ Interface em services!
├── ui/              # ❌ Estrutura confusa
├── utils/           # ❌ DataSource em utils!
├── viewmodels/      # ❌ Instancia impl diretamente
└── widgets/         # ❌ Model em widgets!
```

### Depois (Projeto Refatorado):
```
lib/
├── core/                        # ✅ Recursos compartilhados
└── features/todos/              # ✅ Feature-first
    ├── data/                    # ✅ Camada de dados
    ├── domain/                  # ✅ Camada de domínio
    └── presentation/            # ✅ Camada de apresentação
```

### Principais Correções:
1. ✅ Reorganização feature-first (escalável)
2. ✅ Separação clara de camadas (Clean Architecture)
3. ✅ Injeção de dependência no ViewModel
4. ✅ TodoViewModel depende da interface, não da implementação
5. ✅ DataSources movidos para `data/datasources/`
6. ✅ Models movidos para `data/models/`
7. ✅ Entities movidos para `domain/entities/`
8. ✅ Interfaces movidas para `domain/repositories/`
9. ✅ UI movida para `presentation/pages/`
10. ✅ Erros movidos para `core/errors/`

---

## 🎓 Conclusão

Este projeto demonstra:
- ✅ **Clean Architecture** com separação clara de responsabilidades
- ✅ **Feature-first** organização escalável
- ✅ **SOLID principles** (SRP, DIP)
- ✅ **Repository Pattern** centralizando acesso a dados
- ✅ **Dependency Injection** facilitando testes e manutenção
- ✅ **Error Handling** adequado em todas as camadas
- ✅ **Parsing JSON** isolado na camada de dados
- ✅ **Validação** no ViewModel (camada de apresentação)

A estrutura está pronta para escalar e receber novas features sem comprometer a organização! 🚀
