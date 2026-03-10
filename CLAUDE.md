# 🎮 STUDYQUEST - CONTEXTO PARA CLAUDE CODE

**📅 Última Atualização:** 09 de Março de 2026  
**🎯 Versão:** 9.4  
**⚡ Sprint Atual:** 9 (Diário do Explorador) - 85%

---

## 📋 **O QUE É O STUDYQUEST**

StudyQuest é uma **plataforma educacional gamificada** que transforma o aprendizado em aventuras épicas. Inspirado no Duolingo e no antigo NOJI, combina gamificação brasileira com inteligência artificial adaptativa.

```yaml
Público-Alvo: Estudantes 13-25 anos (Ensino Médio ao Superior)
Diferencial: Gamificação contextualizada + IA adaptativa + Identidade brasileira
Plataforma: Web (Flutter) - iOS/Android futuro
```

---

## 🛠️ **STACK TECNOLÓGICO**

```yaml
Framework: Flutter 3.32.2
State Management: Riverpod
Navegação: GoRouter
Backend: Firebase (REST API - SEM SDK)
Linguagem: Dart
```

### **⚠️ IMPORTANTE - FIREBASE REST API:**
O projeto usa **REST API do Firebase**, NÃO usa o SDK Firebase Flutter.
- Autenticação: `identitytoolkit.googleapis.com`
- Firestore: `firestore.googleapis.com`
- Arquivo principal: `lib/core/services/firebase_rest_auth.dart`

**NUNCA sugerir código com:**
- `FirebaseAuth.instance`
- `FirebaseFirestore.instance`
- Qualquer import `package:firebase_*`

---

## 📁 **ESTRUTURA DO PROJETO**

```
lib/
├── core/
│   ├── models/
│   │   └── avatar.dart
│   └── services/
│       ├── firebase_rest_auth.dart  ← AUTH + TOKEN REFRESH
│       └── firebase_service.dart    ← QUESTÕES
├── features/
│   ├── auth/
│   │   └── screens/
│   │       ├── welcome_screen.dart
│   │       ├── login_screen.dart
│   │       ├── register_screen.dart
│   │       └── forgot_password_screen.dart
│   ├── home/
│   │   └── screens/
│   │       ├── home_screen.dart      ← Bottom Nav (5 abas)
│   │       ├── inicio_tab.dart
│   │       ├── diario_tab.dart       ← Sprint 9
│   │       ├── jogar_tab.dart
│   │       ├── ranking_tab.dart
│   │       └── perfil_tab.dart
│   ├── onboarding/
│   │   └── screens/
│   │       └── onboarding_screen.dart ← 8 telas + providers
│   ├── avatar/
│   │   └── screens/
│   │       └── avatar_selection_screen.dart
│   ├── questoes/
│   │   ├── screens/
│   │   │   ├── questao_personalizada_screen.dart
│   │   │   ├── questoes_resultado_screen.dart
│   │   │   └── questoes_gameover_screen.dart
│   │   └── providers/
│   │       └── sessao_questoes_provider.dart
│   ├── niveis/
│   │   ├── models/nivel_model.dart
│   │   ├── providers/nivel_provider.dart
│   │   └── services/nivel_persistence.dart
│   ├── diario/                        ← Sprint 9
│   │   ├── models/
│   │   ├── providers/
│   │   │   ├── diary_provider.dart
│   │   │   └── diary_badges_provider.dart
│   │   ├── screens/
│   │   ├── services/
│   │   │   └── firebase_diary_service.dart
│   │   └── widgets/
│   └── trilha/
│       └── providers/
│           └── recursos_personalizados_provider.dart
└── main.dart
```

---

## 🔑 **PROVIDERS PRINCIPAIS**

```dart
// Autenticação
authProvider              → Estado de auth (logado/anônimo/deslogado)

// Onboarding
onboardingProvider        → Dados do onboarding (nome, série, avatar, etc)

// Níveis e XP
nivelProvider             → NivelUsuario (xpTotal, nivel, tier)

// Sessão de Questões
sessaoQuestoesProvider    → Sessão ativa (questões, índice, tempo)
recursosPersonalizadosProvider → Água e Energia

// Diário
diaryProvider             → Anotações e estatísticas
diaryBadgesProvider       → Badges desbloqueadas
```

---

## 🗄️ **ESTRUTURA FIREBASE**

### **Collections:**
```yaml
questions:          # 350+ questões
  - subject, school_level, difficulty, enunciado, alternativas, etc

users:              # Dados do usuário
  - name, email, school_level, etc

progress:           # Progresso do usuário
  - xp, nivel, completed_questions, etc

diary_entries:      # Anotações do diário
  - user_id, question_id, user_note, emotion, etc

user_xp:            # XP persistido
  - user_id, xpTotal, nivel, etc

user_badges:        # Badges desbloqueadas
  - user_id, badge_id, unlocked_at, etc

user_responses:     # Respostas do usuário
  - question_id, user_answer, is_correct, etc
```

### **Regras Firestore:**
```javascript
match /questions/{questionId} { allow read: if true; allow write: if false; }
match /users/{userId} { allow read, write: if true; }
match /progress/{userId} { allow read, write: if true; }
match /diary_entries/{docId} { allow read, write: if true; }
match /user_responses/{docId} { allow read, write: if true; }
match /user_xp/{docId} { allow read, write: if true; }
match /user_badges/{docId} { allow read, write: if true; }
```

---

## 🎮 **MECÂNICAS DE JOGO**

### **Sistema de Recursos:**
```yaml
Água: Começa 100%, -20% por erro
Energia: Começa 100%, -20% por erro
Saúde: (Água×14 + Energia×4)/100
Game Over: Saúde = 0
Checkpoint: Um recurso = 0 (XP volta ao início da sessão)
```

### **Sistema de Níveis:**
```yaml
Fórmula XP: 100 * (1.15 ^ (nivel - 1))
51+ níveis possíveis
5 Tiers: Iniciante → Aprendiz → Estudioso → Mestre → Lenda
XP por acerto: 10-50 (baseado em dificuldade + multiplicadores)
```

### **Sistema de Badges (Sprint 9):**
```yaml
15+ badges: Primeira Anotação, Estudioso, Transformador, etc
XP por badge: 50-500
Verificação automática via BadgeListenerWrapper
```

---

## 🔧 **PADRÕES DE CÓDIGO**

### **Fazer requisições HTTP ao Firebase:**
```dart
// SEMPRE usar getAuthHeaders() para pegar token válido
final headers = await FirebaseRestAuth.getAuthHeaders();

final response = await http.get(
  Uri.parse('https://firestore.googleapis.com/v1/projects/studyquest-firebase/databases/(default)/documents/COLLECTION'),
  headers: headers,
);
```

### **Verificar usuário logado vs anônimo:**
```dart
final authState = ref.watch(authProvider);
final isAnonymous = authState.user?.isAnonymous ?? true;
final userId = authState.user?.localId;
```

### **Navegação:**
```dart
context.go('/home');      // Substitui a rota
context.push('/profile'); // Empilha a rota
```

---

## ⚠️ **BUGS CONHECIDOS E SOLUÇÕES**

### **Token expira em 1 hora:**
✅ RESOLVIDO: `firebase_rest_auth.dart` tem auto-refresh

### **Sessão pula questão ao pausar:**
✅ RESOLVIDO: `sessaoQuestoesProvider` preserva estado com `isAtiva`

### **Logout apagava dados do usuário logado:**
✅ RESOLVIDO: `perfil_tab.dart` só limpa para anônimo

---

## 📊 **STATUS ATUAL**

```yaml
Sprint 9 (Diário): 85% ✅
  - Fase 1 (Dashboard): ✅ 100%
  - Fase 2 (Anotações): ✅ 100%
  - Fase 3 (Badges): ✅ 85%

Pendências:
  - XP/nível visível para usuário anônimo
  - Spaced Repetition (calendário visual)
  - Tab Insights com gráficos avançados
```

---

## 🚀 **COMANDOS ÚTEIS**

```bash
# Rodar o app
flutter run -d chrome

# Hot restart
R (no terminal)

# Verificar erros
flutter analyze

# Ver estrutura
find lib -name "*.dart" | head -50
```

---

## 📝 **INSTRUÇÕES PARA CLAUDE CODE**

1. **Sempre pergunte antes de editar** - Não altere arquivos sem explicar o que vai fazer
2. **Código completo** - Quando gerar código, gere o arquivo completo para copiar e colar
3. **REST API** - Lembre-se que usamos Firebase REST, não SDK
4. **Teste antes** - Sempre sugira testar após alterações
5. **Commits pequenos** - Sugira commits frequentes para não perder trabalho

---

## 🔗 **DOCUMENTOS IMPORTANTES**

```
/mnt/project/SPRINT_9_PLANO_DIARIO_FASES.md    ← Plano Sprint 9
/mnt/project/STATUS_MESTRE_V8_0.md             ← Status geral
/mnt/project/ROADMAP_V8_CONSOLIDADO.md         ← Roadmap completo
/mnt/project/REGRAS_NEGOCIO_V73_RECURSOS.md    ← Regras de negócio
```

---

**🎯 USE ESTE DOCUMENTO COMO REFERÊNCIA RÁPIDA!**
