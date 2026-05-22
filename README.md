# Mensal

> **Projeto Educacional — Apenas para Uso Não Comercial**
>
> Este projeto foi desenvolvido exclusivamente para fins de aprendizado e estudo. Não deve ser utilizado para nenhuma finalidade comercial, monetização ou lucro de qualquer tipo. Veja a seção [Licença e Termos de Uso](#licença-e-termos-de-uso) para mais detalhes.

---

Mensal é um aplicativo Flutter de controle financeiro pessoal para gerenciar salário e listas de mercado mês a mês. Todo o armazenamento é local — nenhum dado é enviado para servidores externos.

---

## Índice

- [Funcionalidades](#funcionalidades)
- [Telas](#telas)
- [Arquitetura](#arquitetura)
- [Stack de Tecnologias](#stack-de-tecnologias)
- [Como Rodar](#como-rodar)
- [Licença e Termos de Uso](#licença-e-termos-de-uso)

---

## Funcionalidades

**Controle por Mês**
A tela inicial exibe os 12 meses do ano em grade. Cada mês pode conter múltiplos cálculos independentes (ex: "Salário Principal", "Extras", "Mercado Semana 1").

**Dois Tipos de Cálculo**
- **Controle de Salário** — define um valor de renda e adiciona despesas. O app calcula automaticamente a sobra (renda − total das despesas).
- **Lista de Mercado** — define um orçamento e adiciona itens com valor e quantidade. Calcula o total gasto e o saldo restante do orçamento.

**Gestão de Despesas/Itens**
- Adicionar, editar e excluir despesas com descrição, valor e quantidade.
- Suporte a multiplicadores de quantidade (ex: 5 itens × R$ 10,00 = R$ 50,00).
- Reordenar itens por arrastar e soltar.

**Cálculo em Tempo Real**
Totais, sobra e contagem de itens são recalculados automaticamente a cada alteração, sem necessidade de salvar manualmente.

**Copiar entre Meses**
Duplica um cálculo inteiro (com todas as despesas e orçamento) de um mês para outro. Útil para replicar listas fixas mensais.

**Compartilhamento via WhatsApp**
- Exporta a lista de despesas como texto formatado direto para o WhatsApp.
- Gera um código em base64 que pode ser importado em outro dispositivo para sincronização manual.

**Persistência Local**
Todos os dados são salvos no dispositivo via `SharedPreferences` em formato JSON. A chave de cada mês segue o padrão `month_AAAA_MM`.

---

## Telas

| Tela | Descrição |
|---|---|
| **Home** | Grade com os 12 meses do ano. Toque em um mês para ver seus cálculos. |
| **Lista de Cálculos** | Exibe todos os cálculos de um mês com resumo de totais. Permite criar novos cálculos ou copiar de outro mês. |
| **Detalhe do Cálculo** | Visualiza e edita as despesas de um cálculo. Mostra renda/orçamento, total gasto e sobra em tempo real. |
| **Copiar Cálculo** | Seleciona o mês de destino para duplicar um cálculo existente. |

---

## Arquitetura

```
mensal/lib/
├── main.dart                          # Ponto de entrada
├── app_theme.dart                     # Tema global (cores, tipografia)
├── models/
│   └── month_data.dart                # MonthData, Expense, CalculationType
├── screens/
│   ├── home_screen.dart               # Grade de meses
│   ├── month_calculations_screen.dart # Lista de cálculos do mês
│   ├── month_detail_screen.dart       # Detalhe e edição de um cálculo
│   └── copy_calculation_screen.dart   # Cópia entre meses
├── services/
│   └── storage_service.dart           # Leitura/escrita via SharedPreferences
└── widgets/
    ├── month_card.dart                # Card do mês na grade
    ├── expense_tile.dart              # Item de despesa na lista
    ├── add_expense_sheet.dart         # Bottom sheet para adicionar despesa
    ├── add_calculation_sheet.dart     # Bottom sheet para criar cálculo
    └── sobra_bar.dart                 # Barra visual de saldo restante
```

**Modelos principais:**

- `MonthData` — título, tipo (`salary` / `market`), valor de renda/orçamento, lista de despesas e propriedades calculadas (`sobra`, `totalExpenses`, `totalItems`).
- `Expense` — id, descrição, valor e quantidade.
- `CalculationType` — enum com `salary` e `market`.

Não há gerenciamento de estado externo (sem MobX, Provider ou BLoC). O estado é gerenciado localmente em cada tela com `StatefulWidget` e `setState`.

---

## Stack de Tecnologias

| Pacote | Versão | Finalidade |
|---|---|---|
| Flutter | SDK | Framework de UI |
| shared_preferences | ^2.3.0 | Armazenamento local (JSON) |
| intl | ^0.19.0 | Formatação monetária em pt_BR (R$) |
| url_launcher | ^6.3.0 | Deep link para WhatsApp |
| flutter_launcher_icons | ^0.14.0 | Geração de ícones do app (dev) |

**Tema:**
- Primária: `#00796B` (Teal)
- Acento: `#FFB300` (Amber)
- Fundo: `#F2F2F0` (Cinza claro)
- Sobra positiva: `#388E3C` (Verde)
- Sobra negativa: `#D32F2F` (Vermelho)

---

## Como Rodar

**Pré-requisitos:**
- [Flutter SDK](https://docs.flutter.dev/get-started/install) — canal stable, 3.x ou superior
- Android SDK ou Xcode (para plataformas nativas)

```bash
# 1. Clonar o repositório
git clone git@github.com:Lucas-Gomes-hb/mensal.git
cd mensal

# 2. Instalar dependências
flutter pub get

# 3. Rodar no dispositivo ou emulador
flutter run
```

---

## Licença e Termos de Uso

Este projeto é disponibilizado sob a licença **Creative Commons Atribuição-NãoComercial 4.0 Internacional (CC BY-NC 4.0)**.

**Você tem liberdade para:**
- Usar, estudar, copiar, modificar e distribuir este projeto e seu código-fonte.
- Criar trabalhos derivados.
- Compartilhá-lo livremente com outras pessoas.

**Sob as seguintes condições:**
- **Atribuição** — Você deve dar o crédito apropriado ao(s) autor(es) originais e incluir um link para este repositório.
- **NãoComercial** — Você **não pode** usar este projeto, seu código ou qualquer derivado para fins comerciais, monetização, lucro, serviços pagos ou qualquer atividade que gere receita.

Texto completo da licença: [creativecommons.org/licenses/by-nc/4.0/deed.pt](https://creativecommons.org/licenses/by-nc/4.0/deed.pt)

---

> **Este projeto existe exclusivamente para fins educacionais e de estudo.**
> Os autores não se responsabilizam pelo uso indevido do software por terceiros.
> **Este projeto não deve ser utilizado para fins comerciais ou para geração de receita de qualquer tipo.**
