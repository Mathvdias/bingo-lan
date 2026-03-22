# Golden Tests - Bingo App

Este diretório contém os testes golden (visual regression tests) para os widgets principais do aplicativo Bingo.

## 📋 Lista de Golden Tests

### Tests Principais (Alta Prioridade)
- **`bingo_button_golden_test.dart`** - Testes existentes para BingoButton
- **`card_cell_golden_test.dart`** - CardCell em diferentes estados (normal, marked, validated, FREE)
- **`bingo_grid_header_golden_test.dart`** - BingoGridHeader em diferentes temas e tamanhos
- **`bingo_ball_golden_test.dart`** - BingoBall em diferentes estados e tamanhos

### Tests Secundários (Média Prioridade)
- **`bingo_back_button_golden_test.dart`** - BingoBackButton com diferentes estilos
- **`bingo_input_golden_test.dart`** - BingoInput em diferentes estados (normal, focused, senha)
- **`flippable_card_golden_test.dart`** - FlippableCard em diferentes tamanhos e contextos

### Tests Adicionais (Baixa Prioridade)
- **`stroked_text_golden_test.dart`** - StrokedText com diferentes stroke widths e tamanhos

## 🚀 Como Executar

### Executar Todos os Golden Tests
```bash
flutter test test/goldens/
```

### Executar Teste Específico
```bash
# Teste do BingoButton
flutter test test/goldens/bingo_button_golden_test.dart

# Teste do CardCell
flutter test test/goldens/card_cell_golden_test.dart

# Teste do BingoGridHeader
flutter test test/goldens/bingo_grid_header_golden_test.dart

# Teste do BingoBall
flutter test test/goldens/bingo_ball_golden_test.dart

# Teste do BingoBackButton
flutter test test/goldens/bingo_back_button_golden_test.dart

# Teste do BingoInput
flutter test test/goldens/bingo_input_golden_test.dart

# Teste do FlippableCard
flutter test test/goldens/flippable_card_golden_test.dart

# Teste do StrokedText
flutter test test/goldens/stroked_text_golden_test.dart
```

### Atualizar Golden Files (quando mudanças intencionais)
```bash
# Atualizar todos os golden files
flutter test test/goldens/ --update-goldens

# Atualizar golden file específico
flutter test test/goldens/bingo_button_golden_test.dart --update-goldens
```

### Comparar com Golden Files Existente
```bash
# Comparar e mostrar diferenças
flutter test test/goldens/ --golden
```

## 📱 Configuração

### Variáveis de Ambiente
- **CI=true** - Tests são automaticamente skipados em ambiente CI
- **FLUTTER_TEST** - Variável automática do Flutter test runner

### Temas Testados
- **Tema Claro** - ColorScheme.light com cores AppColors
- **Tema Escuro** - ColorScheme.dark com cores AppColors
- **Tema Customizado** - Configurações específicas para cada widget

## 🎯 Coverage de Widgets

### Widgets Cobertos
✅ **BingoButton** - Estados padrão, cores customizadas  
✅ **CardCell** - Normal, marked, validated, FREE center  
✅ **BingoGridHeader** - Layout responsivo, temas claro/escuro  
✅ **BingoBall** - Normal/drawn, diferentes tamanhos, 1/2 dígitos  
✅ **BingoBackButton** - Padrão, cores customizadas, tema escuro  
✅ **BingoInput** - Normal, focused, senha, tema escuro  
✅ **FlippableCard** - Frente/verso, tamanhos, texto longo  
✅ **StrokedText** - Diferentes stroke widths, tamanhos  

### Widgets Pendentes
⏳ **BannerAdWidget** - Requer mock de Google Mobile Ads  
⏳ **BingoGrid** - Widget complexo com SliverGrid  
⏳ **BingoScaffold** - Requer contexto de navegação  
⏳ **ViewModelProvider** - Widget de state management  

## 🖼️ Golden Files Gerados

### CardCell (5 arquivos)
- `card_cell_normal.png` - Estado normal
- `card_cell_free.png` - Center FREE
- `card_cell_marked.png` - Estado marked
- `card_cell_validated.png` - Estado validated
- `card_cell_all_states.png` - Todos os estados lado a lado

### BingoGridHeader (4 arquivos)
- `bingo_grid_header_default.png` - Layout padrão
- `bingo_grid_header_dark.png` - Tema escuro
- `bingo_grid_header_small.png` - Tamanho reduzido
- `bingo_grid_header_full_width.png` - Largura total

### BingoBall (8 arquivos)
- `bingo_ball_normal.png` - Estado normal
- `bingo_ball_drawn.png` - Estado sorteado
- `bingo_ball_small.png` - Tamanho pequeno (40px)
- `bingo_ball_large.png` - Tamanho grande (80px)
- `bingo_ball_single_digit.png` - Números de 1 dígito
- `bingo_ball_double_digit.png` - Números de 2 dígitos
- `bingo_ball_variety.png` - Variedade de estados
- `bingo_ball_dark_theme.png` - Tema escuro

### BingoBackButton (6 arquivos)
- `bingo_back_button_default.png` - Estado padrão
- `bingo_back_button_custom_bg.png` - Cor customizada
- `bingo_back_button_custom_handler.png` - Handler customizado
- `bingo_back_button_dark_theme.png` - Tema escuro
- `bingo_back_button_in_appbar.png` - Em AppBar
- `bingo_back_button_variety.png` - Múltiplos estilos

### BingoInput (8 arquivos)
- `bingo_input_default.png` - Estado padrão
- `bingo_input_with_text.png` - Com texto preenchido
- `bingo_input_password.png` - Modo senha
- `bingo_input_focused.png` - Estado focado
- `bingo_input_dark_theme.png` - Tema escuro
- `bingo_input_small.png` - Tamanho pequeno
- `bingo_input_full_width.png` - Largura total
- `bingo_input_variety.png` - Múltiplos estados

### FlippableCard (8 arquivos)
- `flippable_card_front.png` - Lado frontal
- `flippable_card_dark_theme.png` - Tema escuro
- `flippable_card_small.png` - Tamanho pequeno
- `flippable_card_large.png` - Tamanho grande
- `flippable_card_long_text.png` - Texto longo
- `flippable_card_multiple.png` - Múltiplos cards
- `flippable_card_in_column.png` - Em coluna
- `flippable_card_after_tap.png` - Após interação

### StrokedText (10 arquivos)
- `stroked_text_simple.png` - Texto simples
- `stroked_text_long.png` - Texto longo
- `stroked_text_normal_width.png` - Stroke width normal
- `stroked_text_thin_width.png` - Stroke width fino
- `stroked_text_thick_width.png` - Stroke width grosso
- `stroked_text_dark_theme.png` - Tema escuro
- `stroked_text_multiple_sizes.png` - Múltiplos tamanhos
- `stroked_text_multiple_widths.png` - Múltiplos stroke widths
- `stroked_text_in_container.png` - Dentro de container
- `stroked_text_special_chars.png` - Caracteres especiais

## ⚠️ Limitações e Considerações

### Assets de Imagem
- **FlippableCard** usa `assets/images/test_image.png` que não existe
- Em produção, usar imagens reais ou mock assets
- Considerar usar `MemoryImage` para testes consistentes

### Google Fonts
- Tests evitam Google Fonts para não depender de rede
- Usam fontes system/defaults para consistência

### Plataformas
- Tests executam em todas as plataformas suportadas
- Golden files são platform-specific quando necessário

### Performance
- Tests podem ser demorados devido a renderização
- Considerar executar em paralelo em CI

## 🐛 Troubleshooting

### Erros Comuns

**"Golden file not found"**
```bash
# Gerar golden files iniciais
flutter test test/goldens/ --update-goldens
```

**"Golden test failed"**
```bash
# Verificar diferenças
flutter test test/goldens/ --golden

# Se mudança for intencional, atualizar
flutter test test/goldens/ --update-goldens
```

**"Asset not found"**
- Verificar se `assets/images/test_image.png` existe
- Criar asset de teste ou usar placeholder

**"Font rendering differences"**
- Usar fontes system em vez de Google Fonts
- Verificar consistência entre plataformas

### Debug de Golden Tests

```bash
# Executar com verbose output
flutter test test/goldens/ --verbose

# Executar teste específico com debug
flutter test test/goldens/bingo_button_golden_test.dart --verbose

# Parar no primeiro erro
flutter test test/goldens/ --stop-on-first-failure
```

## 🔄 CI/CD Integration

### GitHub Actions
```yaml
- name: Run Golden Tests
  run: |
    flutter test test/goldens/ --update-goldens
    
- name: Upload Golden Files
  if: failure()
  uses: actions/upload-artifact@v3
  with:
    name: golden-files
    path: test/goldens/failures/
```

### Estratégia de CI
1. **Pull Requests**: Comparar com branch base
2. **Main Branch**: Gerar novos golden files
3. **Release**: Validar consistência visual

## 📈 Melhorias Futuras

### Short Term
- [ ] Adicionar tests para BannerAdWidget (mock)
- [ ] Adicionar tests para BingoGrid
- [ ] Melhorar coverage de edge cases

### Long Term
- [ ] Tests de acessibilidade com golden
- [ ] Tests de internacionalização
- [ ] Tests de performance com golden
- [ ] Integração com visual regression tools

### Automatização
- [ ] Auto-update golden files em PRs aprovadas
- [ ] Integration com screenshot services
- [ ] Dashboard de visual regression

## 📝 Boas Práticas

### Ao Criar Novos Golden Tests
1. **Testar múltiplos estados** - normal, hover, pressed, disabled
2. **Testar diferentes temas** - claro, escuro, customizado
3. **Testar responsividade** - diferentes tamanhos
4. **Testar edge cases** - textos longos, caracteres especiais
5. **Usar dados consistentes** - evitar timestamps, IDs aleatórios

### Ao Atualizar Golden Files
1. **Verificar se mudança é intencional**
2. **Testar em múltiplas plataformas**
3. **Documentar motivo da mudança**
4. **Atualizar documentação se necessário**

### Manutenção
1. **Revisar periodicamente** se ainda são relevantes
2. **Remover tests obsoletos**
3. **Adicionar novos widgets** conforme implementados
4. **Manter documentação atualizada**
