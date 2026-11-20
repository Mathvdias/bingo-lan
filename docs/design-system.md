# 🎨 1. Fundações (Design Tokens)

Aqui definimos as variáveis que serão usadas em todo o app.

### 1.1. Paleta de Cores (Pastel & Alto Contraste)

Todas as cores de fundo são suaves, mas o texto e as bordas são sempre **Preto Puro** (`#000000`).

| Token | Hex | Nome | Uso |
| --- | --- | --- | --- |
| **Primary** | `#FFEB3B` | Amarelo Bingo | Botões de Ação (CTA), Destaques. |
| **Secondary** | `#4FC3F7` | Azul Céu | Informações, Links, Player 2. |
| **Success** | `#AED581` | Verde Feijão | Confirmações, Bolinhas Sorteadas. |
| **Error** | `#FF8A80` | Vermelho Tomate | Alertas, Botão Sair, Bingo Falso. |
| **Surface** | `#FFFDF5` | Creme Suave | **Fundo das Telas** (Não use branco puro #FFF). |
| **Card** | `#FFFFFF` | Branco Puro | Fundo de Cards e Cartelas. |
| **Outline** | `#121212` | Preto Tinta | Bordas, Textos, Ícones. |

### 1.2. Tipografia (Legibilidade & Personalidade)

Recomendo usar **Google Fonts**.

* **Títulos (Display):** **`Fredoka`** ou **`Outfit`**. (Fontes arredondadas, amigáveis, lembram números de bingo).
* **Corpo (Body):** **`Inter`** ou **`Mulish`**. (Excelente leitura em telas pequenas).

| Token | Tamanho | Peso | Line Height | Uso |
| --- | --- | --- | --- | --- |
| `H1` | 32px | Bold | 1.2 | Título da Sala, "BINGO!" |
| `H2` | 24px | SemiBold | 1.3 | Subtítulos, Cabeçalho da Cartela |
| `H3` | 20px | Medium | 1.4 | Nomes de Jogadores |
| `Body` | 16px | Regular | 1.5 | Instruções, Listas |
| `Number` | 48px+ | Bold | 1.0 | O número sorteado gigante |

### 1.3. Bordas & Sombras (A Assinatura Visual)

Aqui está o segredo do estilo. **Nada de sombras esfumaçadas.**

* **Borda Padrão:** `2.0px` Solid Black (`#121212`).
* **Borda Grossa (Focus):** `4.0px` Solid Black.
* **Radius (Arredondamento):**
* *Small:* `8px` (Chips, Inputs).
* *Medium:* `16px` (Cards, Botões).
* *Large:* `24px` (Modais, Dialogs).


* **Hard Shadow (Sombra Rígida):**
* `Offset(4, 4)`, `Blur(0)`, `Color(Black)`.
* Isso cria o efeito 3D "cartunesco".



---

# ⚛️ 2. Componentes (Atomic Design)

Vamos traduzir isso para componentes Flutter que você pode criar na pasta `shared/ui`.

## 🟠 Átomos (Componentes Indivisíveis)

### A. Botão Primário (`BingoButton`)

Um botão amarelo, com borda preta e sombra dura. Ao clicar, a sombra desaparece (efeito de "afundar").

* **Background:** Amarelo (`Primary`).
* **Border:** 2px Preto.
* **Shadow:** 4px Preto (sem blur).
* **Text:** Preto Bold.

```dart
// Exemplo visual da propriedade
Container(
  decoration: BoxDecoration(
    color: AppColors.primary,
    border: Border.all(color: Colors.black, width: 2),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)
    ],
  ),
  child: Center(child: Text("GRITAR BINGO!", style: ...)),
)

```

### B. Input de Texto (`BingoInput`)

Estilo "Caixa de Formulário".

* **Background:** Branco.
* **Border:** 2px Preto.
* **Focus:** O fundo muda para Amarelo muito claro.

### C. A Bola de Bingo (`BingoBall`)

* **Shape:** Círculo.
* **Background:** Branco (se não sorteada) ou Verde (se sorteada).
* **Border:** 2px Preto.
* **Content:** Número centralizado (Fonte `Fredoka`).

---

## 🧬 Moléculas (Combinações)

### A. Célula da Cartela (`CardCell`)

Usado na Grid 5x5.

* Composto por: `Container` (quadrado) + `Text` (número).
* **Estado:**
* *Normal:* Fundo Branco.
* *Marcado (Touch):* Fundo Amarelo + Ícone de "Feijão" ou Círculo desenhado por cima.
* *Validado (Vitória):* Fundo Verde.



### B. Header de Coluna (`BingoHeader`)

As letras B-I-N-G-O no topo.

* Cada letra tem uma cor de fundo pastel diferente para ajudar na identificação rápida.
* **B:** Vermelho Pastel.
* **I:** Laranja Pastel.
* **N:** Amarelo Pastel.
* **G:** Verde Pastel.
* **O:** Azul Pastel.



---

## 🦠 Organismos (Seções Complexas)

### A. A Cartela (`BingoGrid`)

* **Layout:** `GridView.count(crossAxisCount: 5)`.
* **Espaçamento:** `8px` entre as células.
* **Responsividade:** Deve manter a proporção 1:1 (quadrada) e caber na largura da tela com margem de `16px`.

### B. O Painel do Host

* Destaque total para o número atual (Tamanho 120px).
* Lista de rolagem horizontal com os "Últimos 5 números".

---

# 📏 3. Diretrizes de UX e Responsividade

### 3.1. Acessibilidade (Prioridade Máxima)

Como Bingo é jogado por idosos:

1. **Touch Targets:** Nenhum botão deve ter menos de `48x48` pixels (físicos).
2. **Feedback Sonoro:** Todo clique em botão ou marcação de cartela deve ter um som de "Click" ou "Pop" satisfatório (use `SystemSound.play(SystemSoundType.click)`).
3. **Haptic Feedback:** Vibrar levemente ao marcar um número.

### 3.2. Responsividade (Layout Builder)

O app deve funcionar em celulares estreitos e tablets.

* **Mobile (< 600px):**
* A cartela ocupa 90% da largura.
* Botões de ação fixos no rodapé (`BottomAppBar`).


* **Tablet (> 600px):**
* Layout em duas colunas.
* Esquerda: Cartela Grande.
* Direita: Chat, Histórico de números e Botões de Ação.



---

# 🛠️ Implementação no Flutter (ThemeData)

Para facilitar seu desenvolvimento, configure o `ThemeData` no `main.dart` para já aplicar esse estilo nativamente:

```dart
final bingoTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: Color(0xFFFFFDF5), // Creme Surface
  fontFamily: 'Fredoka', // Fonte principal
  
  // Cores do Scheme
  colorScheme: ColorScheme.light(
    primary: Color(0xFFFFEB3B),    // Amarelo
    onPrimary: Colors.black,       // Texto no Amarelo
    secondary: Color(0xFF4FC3F7),  // Azul
    onSecondary: Colors.black,
    surface: Color(0xFFFFFFFF),    // Cards
    onSurface: Colors.black,
    error: Color(0xFFFF8A80),
  ),

  // Estilo Padrão dos Botões (ElevatedButton)
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFFFFEB3B), // Amarelo
      foregroundColor: Colors.black,      // Texto Preto
      elevation: 0,                       // Sem sombra padrão (faremos custom)
      side: BorderSide(color: Colors.black, width: 2), // Borda Preta
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    ),
  ),
  
  // Estilo dos Cards
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: Colors.black, width: 2),
      borderRadius: BorderRadius.circular(16),
    ),
  ),
);

```

### Como fazer o botão com "Hard Shadow" (Sombra Dura)?

O Flutter não tem "Hard Shadow" nativo no `ElevatedButton`. Você criará um componente `BingoButton`:

```dart
class BingoButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const BingoButton({
    required this.label, 
    required this.onPressed,
    this.color = const Color(0xFFFFEB3B), // Amarelo Padrão
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: [
            // Sombra Dura (Sem blur)
            BoxShadow(
              color: Colors.black,
              offset: Offset(4, 4), // Deslocamento X, Y
              blurRadius: 0,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Center(
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}

```

Esse Design System garante que seu app seja **único**, **acessível** e tenha aquela cara de "Bingo Moderno" que você quer. Aprovado?