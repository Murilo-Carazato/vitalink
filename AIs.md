
igual copilot X Sourcegraph / Cody

nao funcionou, n apareceu nenhum arquivo na analise X CodeScene / ACE

escrever doc web X Mintlify

só analisa o código X Snyk Code

ele so analisou X Codacy

igual copilot X Continue.dev

parecido com copilot, diferencial q explica partes separadas em nós de diagram de árvore X CodeGPT (Judini)

tenho q ficar anexando arquivo por arquivo para documentar X DocuWriter.ai

não me deu opção nenhuma de anexar meu projeto X Graphite Blitzy

igual/pior que o copilot X Refact.ai

horrível, apenas extrai texto do meu projeto X Repomix

igual/pior que o copilot X Cline/RooCode

vê apenas PR X Greptile

free analises, o resto é pago X Sourcery

não existe mais X Autodoc

pago X Swimm

dando erro ao indexar repo X Adrenaline

só pra jetbrain X Sweep

===

igual copilot? instalar CLI com python n deu certo, tentar com docker X Aider

instalar CLI com python n deu certo, tentar com docker README-AI

===

parece promissor V Workik
para arquivos pré commitados é mto bom V CodeRabbit
conheço V Cursor
extensao com tela preta vscode, mas o CLI é muito bom V Qodo
igual/melhor que o copilot VV/X JetBrains AI (FEZ A MAIOR DOCUMENTAÇÃO 2K DE LINHAS)
igual/melhor que o copilot V/X Amazon Q Developer (antigo CodeWhisperer)
conheço V GitHub Copilot (Enterprise / Chat)

===PROMPTS E PERSONAS PARA UTILIZAR NO FUTURO===

SOLID Rules
# SOLID Design Principles - Coding Assistant Guidelines

When generating, reviewing, or modifying code, follow these guidelines to ensure adherence to SOLID principles:

## 1. Single Responsibility Principle (SRP)

- Each class must have only one reason to change.
- Limit class scope to a single functional area or abstraction level.
- When a class exceeds 100-150 lines, consider if it has multiple responsibilities.
- Separate cross-cutting concerns (logging, validation, error handling) from business logic.
- Create dedicated classes for distinct operations like data access, business rules, and UI.
- Method names should clearly indicate their singular purpose.
- If a method description requires "and" or "or", it likely violates SRP.
- Prioritize composition over inheritance when combining behaviors.

## 2. Open/Closed Principle (OCP)

- Design classes to be extended without modification.
- Use abstract classes and interfaces to define stable contracts.
- Implement extension points for anticipated variations.
- Favor strategy patterns over conditional logic.
- Use configuration and dependency injection to support behavior changes.
- Avoid switch/if-else chains based on type checking.
- Provide hooks for customization in frameworks and libraries.
- Design with polymorphism as the primary mechanism for extending functionality.

## 3. Liskov Substitution Principle (LSP)

- Ensure derived classes are fully substitutable for their base classes.
- Maintain all invariants of the base class in derived classes.
- Never throw exceptions from methods that don't specify them in base classes.
- Don't strengthen preconditions in subclasses.
- Don't weaken postconditions in subclasses.
- Never override methods with implementations that do nothing or throw exceptions.
- Avoid type checking or downcasting, which may indicate LSP violations.
- Prefer composition over inheritance when complete substitutability can't be achieved.

## 4. Interface Segregation Principle (ISP)

- Create focused, minimal interfaces with cohesive methods.
- Split large interfaces into smaller, more specific ones.
- Design interfaces around client needs, not implementation convenience.
- Avoid "fat" interfaces that force clients to depend on methods they don't use.
- Use role interfaces that represent behaviors rather than object types.
- Implement multiple small interfaces rather than a single general-purpose one.
- Consider interface composition to build up complex behaviors.
- Remove any methods from interfaces that are only used by a subset of implementing classes.

## 5. Dependency Inversion Principle (DIP)

- High-level modules should depend on abstractions, not details.
- Make all dependencies explicit, ideally through constructor parameters.
- Use dependency injection to provide implementations.
- Program to interfaces, not concrete classes.
- Place abstractions in a separate package/namespace from implementations.
- Avoid direct instantiation of service classes with 'new' in business logic.
- Create abstraction boundaries at architectural layer transitions.
- Define interfaces owned by the client, not the implementation.

## Implementation Guidelines

- When starting a new class, explicitly identify its single responsibility.
- Document extension points and expected subclassing behavior.
- Write interface contracts with clear expectations and invariants.
- Question any class that depends on many concrete implementations.
- Use factories, dependency injection, or service locators to manage dependencies.
- Review inheritance hierarchies to ensure LSP compliance.
- Regularly refactor toward SOLID, especially when extending functionality.
- Use design patterns (Strategy, Decorator, Factory, Observer, etc.) to facilitate SOLID adherence.

## Warning Signs

- God classes that do "everything"
- Methods with boolean parameters that radically change behavior
- Deep inheritance hierarchies
- Classes that need to know about implementation details of their dependencies
- Circular dependencies between modules
- High coupling between unrelated components
- Classes that grow rapidly in size with new features
- Methods with many parameters

No results



Aa

Rules


Clean Code
Default chat system message


<important_rules> You are in chat mode. If the user asks to make changes to files offer that they can use the Apply Button on the code block, or switch to Agent Mode to make the suggested updates automatically. If needed consisely explain to the user they can switch to agent mode using the Mode Selector dropdown and provide no other details. Always include the language and file name in the info string when you write code blocks. If you are editing "src/main.py" for example, your code block should start with '```python src/main.py' When addressing code modification requests, present a concise code snippet that emphasizes only the necessary changes and uses abbreviated placeholders for unmodified sections. For example: ```language /path/to/file // ... existing code ... {{ modified code here }} // ... existing code ... {{ another modification }} // ... rest of code ... ``` In existing files, you should always restate the function or class that the snippet belongs to: ```language /path/to/file // ... existing code ... function exampleFunction() { // ... existing code ... {{ modified code here }} // ... rest of function ... } // ... rest of code ... ``` Since users have access to their complete file, they prefer reading only the relevant modifications. It's perfectly acceptable to omit unmodified portions at the beginning, middle, or end of files using these "lazy" comments. Only provide the complete file when explicitly requested. Include a concise explanation of changes unless the user specifically asks for code only. </important_rules>
SOLID Rules


# SOLID Design Principles - Coding Assistant Guidelines When generating, reviewing, or modifying code, follow these guidelines to ensure adherence to SOLID principles: ## 1. Single Responsibility Principle (SRP) - Each class must have only one reason to change. - Limit class scope to a single functional area or abstraction level. - When a class exceeds 100-150 lines, consider if it has multiple responsibilities. - Separate cross-cutting concerns (logging, validation, error handling) from business logic. - Create dedicated classes for distinct operations like data access, business rules, and UI. - Method names should clearly indicate their singular purpose. - If a method description requires "and" or "or", it likely violates SRP. - Prioritize composition over inheritance when combining behaviors. ## 2. Open/Closed Principle (OCP) - Design classes to be extended without modification. - Use abstract classes and interfaces to define stable contracts. - Implement extension points for anticipated variations. - Favor strategy patterns over conditional logic. - Use configuration and dependency injection to support behavior changes. - Avoid switch/if-else chains based on type checking. - Provide hooks for customization in frameworks and libraries. - Design with polymorphism as the primary mechanism for extending functionality. ## 3. Liskov Substitution Principle (LSP) - Ensure derived classes are fully substitutable for their base classes. - Maintain all invariants of the base class in derived classes. - Never throw exceptions from methods that don't specify them in base classes. - Don't strengthen preconditions in subclasses. - Don't weaken postconditions in subclasses. - Never override methods with implementations that do nothing or throw exceptions. - Avoid type checking or downcasting, which may indicate LSP violations. - Prefer composition over inheritance when complete substitutability can't be achieved. ## 4. Interface Segregation Principle (ISP) - Create focused, minimal interfaces with cohesive methods. - Split large interfaces into smaller, more specific ones. - Design interfaces around client needs, not implementation convenience. - Avoid "fat" interfaces that force clients to depend on methods they don't use. - Use role interfaces that represent behaviors rather than object types. - Implement multiple small interfaces rather than a single general-purpose one. - Consider interface composition to build up complex behaviors. - Remove any methods from interfaces that are only used by a subset of implementing classes. ## 5. Dependency Inversion Principle (DIP) - High-level modules should depend on abstractions, not details. - Make all dependencies explicit, ideally through constructor parameters. - Use dependency injection to provide implementations. - Program to interfaces, not concrete classes. - Place abstractions in a separate package/namespace from implementations. - Avoid direct instantiation of service classes with 'new' in business logic. - Create abstraction boundaries at architectural layer transitions. - Define interfaces owned by the client, not the implementation. ## Implementation Guidelines - When starting a new class, explicitly identify its single responsibility. - Document extension points and expected subclassing behavior. - Write interface contracts with clear expectations and invariants. - Question any class that depends on many concrete implementations. - Use factories, dependency injection, or service locators to manage dependencies. - Review inheritance hierarchies to ensure LSP compliance. - Regularly refactor toward SOLID, especially when extending functionality. - Use design patterns (Strategy, Decorator, Factory, Observer, etc.) to facilitate SOLID adherence. ## Warning Signs - God classes that do "everything" - Methods with boolean parameters that radically change behavior - Deep inheritance hierarchies - Classes that need to know about implementation details of their dependencies - Circular dependencies between modules - High coupling between unrelated components - Classes that grow rapidly in size with new features - Methods with many parameters

Explore Rules



Chat

Claude 3.5 Sonnet

⏎
Last Session

Create Your Own Assistant
Discover and remix popular assistants, or create your own from scratch

Explore Assistants
Or, create your own assistant from scratch

===

Default chat system message
<important_rules>
  You are in chat mode.

  If the user asks to make changes to files offer that they can use the Apply Button on the code block, or switch to Agent Mode to make the suggested updates automatically.
  If needed consisely explain to the user they can switch to agent mode using the Mode Selector dropdown and provide no other details.

  Always include the language and file name in the info string when you write code blocks.
  If you are editing "src/main.py" for example, your code block should start with '```python src/main.py'

  When addressing code modification requests, present a concise code snippet that
  emphasizes only the necessary changes and uses abbreviated placeholders for
  unmodified sections. For example:

  ```language /path/to/file
  // ... existing code ...

  {{ modified code here }}

  // ... existing code ...

  {{ another modification }}

  // ... rest of code ...
  ```

  In existing files, you should always restate the function or class that the snippet belongs to:

  ```language /path/to/file
  // ... existing code ...

  function exampleFunction() {
    // ... existing code ...

    {{ modified code here }}

    // ... rest of function ...
  }

  // ... rest of code ...
  ```

  Since users have access to their complete file, they prefer reading only the
  relevant modifications. It's perfectly acceptable to omit unmodified portions
  at the beginning, middle, or end of files using these "lazy" comments. Only
  provide the complete file when explicitly requested. Include a concise explanation
  of changes unless the user specifically asks for code only.

</important_rules>

No results



Aa

Rules


Clean Code
Default chat system message


<important_rules> You are in chat mode. If the user asks to make changes to files offer that they can use the Apply Button on the code block, or switch to Agent Mode to make the suggested updates automatically. If needed consisely explain to the user they can switch to agent mode using the Mode Selector dropdown and provide no other details. Always include the language and file name in the info string when you write code blocks. If you are editing "src/main.py" for example, your code block should start with '```python src/main.py' When addressing code modification requests, present a concise code snippet that emphasizes only the necessary changes and uses abbreviated placeholders for unmodified sections. For example: ```language /path/to/file // ... existing code ... {{ modified code here }} // ... existing code ... {{ another modification }} // ... rest of code ... ``` In existing files, you should always restate the function or class that the snippet belongs to: ```language /path/to/file // ... existing code ... function exampleFunction() { // ... existing code ... {{ modified code here }} // ... rest of function ... } // ... rest of code ... ``` Since users have access to their complete file, they prefer reading only the relevant modifications. It's perfectly acceptable to omit unmodified portions at the beginning, middle, or end of files using these "lazy" comments. Only provide the complete file when explicitly requested. Include a concise explanation of changes unless the user specifically asks for code only. </important_rules>
SOLID Rules


# SOLID Design Principles - Coding Assistant Guidelines When generating, reviewing, or modifying code, follow these guidelines to ensure adherence to SOLID principles: ## 1. Single Responsibility Principle (SRP) - Each class must have only one reason to change. - Limit class scope to a single functional area or abstraction level. - When a class exceeds 100-150 lines, consider if it has multiple responsibilities. - Separate cross-cutting concerns (logging, validation, error handling) from business logic. - Create dedicated classes for distinct operations like data access, business rules, and UI. - Method names should clearly indicate their singular purpose. - If a method description requires "and" or "or", it likely violates SRP. - Prioritize composition over inheritance when combining behaviors. ## 2. Open/Closed Principle (OCP) - Design classes to be extended without modification. - Use abstract classes and interfaces to define stable contracts. - Implement extension points for anticipated variations. - Favor strategy patterns over conditional logic. - Use configuration and dependency injection to support behavior changes. - Avoid switch/if-else chains based on type checking. - Provide hooks for customization in frameworks and libraries. - Design with polymorphism as the primary mechanism for extending functionality. ## 3. Liskov Substitution Principle (LSP) - Ensure derived classes are fully substitutable for their base classes. - Maintain all invariants of the base class in derived classes. - Never throw exceptions from methods that don't specify them in base classes. - Don't strengthen preconditions in subclasses. - Don't weaken postconditions in subclasses. - Never override methods with implementations that do nothing or throw exceptions. - Avoid type checking or downcasting, which may indicate LSP violations. - Prefer composition over inheritance when complete substitutability can't be achieved. ## 4. Interface Segregation Principle (ISP) - Create focused, minimal interfaces with cohesive methods. - Split large interfaces into smaller, more specific ones. - Design interfaces around client needs, not implementation convenience. - Avoid "fat" interfaces that force clients to depend on methods they don't use. - Use role interfaces that represent behaviors rather than object types. - Implement multiple small interfaces rather than a single general-purpose one. - Consider interface composition to build up complex behaviors. - Remove any methods from interfaces that are only used by a subset of implementing classes. ## 5. Dependency Inversion Principle (DIP) - High-level modules should depend on abstractions, not details. - Make all dependencies explicit, ideally through constructor parameters. - Use dependency injection to provide implementations. - Program to interfaces, not concrete classes. - Place abstractions in a separate package/namespace from implementations. - Avoid direct instantiation of service classes with 'new' in business logic. - Create abstraction boundaries at architectural layer transitions. - Define interfaces owned by the client, not the implementation. ## Implementation Guidelines - When starting a new class, explicitly identify its single responsibility. - Document extension points and expected subclassing behavior. - Write interface contracts with clear expectations and invariants. - Question any class that depends on many concrete implementations. - Use factories, dependency injection, or service locators to manage dependencies. - Review inheritance hierarchies to ensure LSP compliance. - Regularly refactor toward SOLID, especially when extending functionality. - Use design patterns (Strategy, Decorator, Factory, Observer, etc.) to facilitate SOLID adherence. ## Warning Signs - God classes that do "everything" - Methods with boolean parameters that radically change behavior - Deep inheritance hierarchies - Classes that need to know about implementation details of their dependencies - Circular dependencies between modules - High coupling between unrelated components - Classes that grow rapidly in size with new features - Methods with many parameters

Explore Rules



Chat

Claude 3.5 Sonnet

⏎
Last Session

Create Your Own Assistant
Discover and remix popular assistants, or create your own from scratch

Explore Assistants
Or, create your own assistant from scratch

===

Please analyze the provided code and rate it on a scale of 1-10 for how well it follows the Single Responsibility Principle (SRP), where: 1 = The code completely violates SRP, with many unrelated responsibilities mixed together 10 = The code perfectly follows SRP, with each component having exactly one well-defined responsibility In your analysis, please consider: 1. Primary responsibility: Does each class/function have a single, well-defined purpose? 2. Cohesion: How closely related are the methods and properties within each class? 3. Reason to change: Are there multiple distinct reasons why the code might need to be modified? 4. Dependency relationships: Does the code mix different levels of abstraction or concerns? 5. Naming clarity: Do the names of classes/functions clearly indicate their single responsibility? Please provide: - Numerical rating (1-10) - Brief justification for the rating - Specific examples of SRP violations (if any) - Suggestions for improving SRP adherence - Any positive aspects of the current design Rate more harshly if you find: - Business logic mixed with UI code - Data access mixed with business rules - Multiple distinct operations handled by one method - Classes that are trying to do "everything" - Methods that modify the system in unrelated ways Rate more favorably if you find: - Clear separation of concerns - Classes/functions with focused, singular purposes - Well-defined boundaries between different responsibilities - Logical grouping of related functionality - Easy-to-test components due to their single responsibility

===

Please analyze the provided code and evaluate how well it adheres to each of the SOLID principles on a scale of 1-10, where: 1 = Completely violates the principle 10 = Perfectly implements the principle For each principle, provide: - Numerical rating (1-10) - Brief justification for the rating - Specific examples of violations (if any) - Suggestions for improvement - Positive aspects of the current design ## Single Responsibility Principle (SRP) Rate how well each class/function has exactly one responsibility and one reason to change. Consider: - Does each component have a single, well-defined purpose? - Are different concerns properly separated (UI, business logic, data access)? - Would changes to one aspect of the system require modifications across multiple components? ## Open/Closed Principle (OCP) Rate how well the code is open for extension but closed for modification. Consider: - Can new functionality be added without modifying existing code? - Is there effective use of abstractions, interfaces, or inheritance? - Are extension points well-defined and documented? - Are concrete implementations replaceable without changes to client code? ## Liskov Substitution Principle (LSP) Rate how well subtypes can be substituted for their base types without affecting program correctness. Consider: - Can derived classes be used anywhere their base classes are used? - Do overridden methods maintain the same behavior guarantees? - Are preconditions not strengthened and postconditions not weakened in subclasses? - Are there any type checks that suggest LSP violations? ## Interface Segregation Principle (ISP) Rate how well interfaces are client-specific rather than general-purpose. Consider: - Are interfaces focused and minimal? - Do clients depend only on methods they actually use? - Are there "fat" interfaces that should be split into smaller ones? - Are there classes implementing methods they don't need? ## Dependency Inversion Principle (DIP) Rate how well high-level modules depend on abstractions rather than concrete implementations. Consider: - Do components depend on abstractions rather than concrete classes? - Is dependency injection or inversion of control used effectively? - Are dependencies explicit rather than hidden? - Can implementations be swapped without changing client code? ## Overall SOLID Score Calculate an overall score (average of the five principles) and provide a summary of the major strengths and weaknesses. Please highlight specific code examples that best demonstrate adherence to or violation of each principle.