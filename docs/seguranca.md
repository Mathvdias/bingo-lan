# 🛡️ Módulo de Segurança & Integridade

## 1. Segurança do Host (Anti-Intrusão e DoS)

Como o Host abre uma porta (8080) no Wi-Fi, qualquer dispositivo na rede poderia tentar conectar. Vamos blindar isso com um **Handshake de Sessão**.

### A. Token de Sessão (O "Convite")

O servidor `shelf` não deve aceitar qualquer conexão WebSocket.

1. Ao criar a sala, o Host gera um **Token Aleatório** (ex: `AbC-99x`).
2. Esse token **não** é divulgado na rede via mDNS (Bonsoir).
3. Ele só é transferido via **QR Code**.

### B. O Fluxo de Conexão Seguro (Handshake)

1. **Jogador:** Scaneia o QR Code do Host.
2. **Jogador:** Abre o WebSocket enviando o token no header ou na primeira mensagem.
* `ws://192.168.0.5:8080?token=AbC-99x`


3. **Host:** Verifica se o token bate.
* Se `token == null` ou `token != sessionToken`: **Desconecta imediatamente** o socket e bane o IP por 5 minutos (Rate Limiting).
* Se `token == ok`: Aceita o jogador.



Isso impede que alguém use um script para varrer a rede e conectar em bingos alheios ou flodar o servidor.

---

## 2. Onboarding via QR Code (Criptografado)

Para facilitar a entrada e garantir que só quem está na festa entre (segurança física), usamos QR Code.

### Estrutura do QR Code (JSON Base64)

Não colocamos o IP puro no QR Code. Codificamos um JSON em Base64 para evitar leitura humana fácil e facilitar o parse.

**Conteúdo do JSON (Payload):**

```json
{
  "v": 1,                // Versão do protocolo
  "t": "wifi",           // Tipo (wifi ou cloud)
  "h": "192.168.0.15",   // Host IP (ou Código da Sala se for nuvem)
  "p": 8080,             // Porta
  "s": "Xy9z7qL2",       // SECRET TOKEN (A chave do cofre)
  "n": "Bingo do Tio Zé" // Nome amigável
}

```

**Bibliotecas Necessárias:**

* **Gerar:** `qr_flutter` (No App do Host).
* **Ler:** `mobile_scanner` (No App do Jogador).

---

## 3. Segurança do Jogo (Anti-Cheat / Anti-Hacker)

O maior risco em jogos P2P é o cliente mentir.

* *Ataque:* O Jogador modifica o app ou usa um script para enviar a mensagem `SHOUT_BINGO` mesmo sem ter completado a cartela.

### Princípio: "Never Trust the Client" (Nunca confie no cliente)

O Host é a **Autoridade Suprema**.

1. **O Jogador grita:** O app do jogador envia: `{"action": "CLAIM_BINGO", "card_id": 1055}`.
2. **O Host valida:** O Host **NÃO** pergunta para o jogador quais números ele marcou.
* O Host pega o `card_id` (1055).
* O Host roda o algoritmo `BingoCard.generate(1055)` localmente.
* O Host compara a matriz gerada com a lista de `drawn_numbers` (números sorteados).


3. **Veredito:**
* Se bateu: O Host envia `GAME_OVER` (Vitória confirmada).
* Se não bateu: O Host envia `INVALID_CLAIM` e o app do jogador toca um som de erro.



**Conclusão:** Mesmo que o sobrinho use um script Python para mandar "Ganhei", o Host vai recalcular matematicamente e rejeitar a fraude instantaneamente.

---

## 4. Mobile Security (App Hardening)

Para proteger seu modelo de monetização (evitar que criem APKs "craqueados" que liberam o Globo grátis), aplicamos proteção no binário.

### A. Obfuscação de Código

No Flutter, isso é nativo. Ao compilar para produção, usamos:
`flutter build apk --obfuscate --split-debug-info=/<project-name>/debug-info`

Isso transforma nomes de classes e funções legíveis (`RevenueCatDriver`) em símbolos ilegíveis (`a.b.c`), dificultando a engenharia reversa.

### B. Detecção de Root/Jailbreak

Dispositivos com Root podem usar ferramentas como *Lucky Patcher* para simular compras falsas.

**Biblioteca:** `flutter_jailbreak_detection`

**Implementação no `AccessControlService`:**

```dart
bool isSecureEnvironment() {
  bool jailbroken = await FlutterJailbreakDetection.jailbroken;
  if (jailbroken) {
    // Decisão de Negócio:
    // Opção A: Bloqueia o app totalmente.
    // Opção B: Desabilita funcionalidades PRO (Host).
    return false; 
  }
  return true;
}

```

---

## 5. Atualização da Documentação Técnica (BOM)

Adicionar ao `pubspec.yaml` do `bingo_core` e `bingo_app`:

**No `bingo_app` (UI de QR e Scanner):**

```yaml
dependencies:
  qr_flutter: ^4.1.0        # Exibir QR no Host
  mobile_scanner: ^3.5.5    # Ler QR no Jogador

```

**No `bingo_core` (Lógica de Segurança):**

```yaml
dependencies:
  crypto: ^3.0.3            # Para gerar Tokens/Hashes seguros
  flutter_jailbreak_detection: ^1.5.0 # Segurança Mobile

```

---

## 6. Fluxo de Usuário Atualizado (Com Segurança)

### Novo Fluxo do Host (Criar Sala)

1. Host clica em "Criar Sala Wi-Fi".
2. `LocalShelfDriver` inicia e gera um **Token Secreto**.
3. Host exibe uma tela com um **QR Code Grande**.
4. O servidor fica em modo "Aguardando Jogadores".

### Novo Fluxo do Jogador (Entrar)

1. Jogador clica em "Entrar na Sala".
2. Câmera abre (`mobile_scanner`).
3. Lê o QR Code -> Extrai IP e Token.
4. O App tenta conectar no WebSocket passando o Token.
5. Conexão estabelecida!

**E se a câmera não funcionar?**
O Host pode clicar no QR Code para revelar o "Código Manual" (que seria o IP + um PIN curto de 4 dígitos gerado a partir do token) para o jogador digitar manualmente.

---

Essa camada fecha as brechas de segurança tanto de **Rede** (intrusos), **Lógica** (trapaceiros) e **Financeiro** (pirataria). Podemos considerar o TDD finalizado com esse módulo?