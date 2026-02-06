#!/bin/bash
# migrate_firebase_40_questoes_bash_puro.sh
# Script 100% BASH para migrar 40 questões EN → PT no Firebase
# Versão: 2.0 - BASH PURO (sem Python)
# Data: 29 de outubro de 2025

set -e  # Parar em caso de erro

# ===== CONFIGURAÇÃO =====
FIREBASE_PROJECT="studyquest-app-banco"
FIREBASE_URL="https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT}/databases/(default)/documents/questions"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}🔄 MIGRAÇÃO FIREBASE - 40 QUESTÕES EN → PT${NC}"
echo -e "${BLUE}   100% BASH PURO (sem Python)${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""
echo "📋 Projeto: ${FIREBASE_PROJECT}"
echo "🎯 Objetivo: Padronizar nomenclatura PT"
echo "📊 Total: 40 questões"
echo ""

# ===== VERIFICAR DEPENDÊNCIAS =====
echo -e "${YELLOW}🔍 Verificando dependências...${NC}"

if ! command -v curl &> /dev/null; then
    echo -e "${RED}❌ curl não encontrado. Instale: brew install curl${NC}"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo -e "${RED}❌ jq não encontrado. Instale: brew install jq${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Dependências OK (curl + jq)${NC}"
echo ""

# ===== LISTA DAS 40 QUESTÕES EN =====
questoes_en=(
    "EM1_BIO_001"
    "EM1_BIO_002"
    "EM1_BIO_003"
    "EM1_MAT_001"
    "EM1_MAT_002"
    "EM1_MAT_003"
    "EM1_MAT_004"
    "EM1_MAT_005"
    "EM1_MAT_006"
    "EM1_MAT_007"
    "EM1_MAT_008"
    "EM1_POR_001"
    "EM1_POR_002"
    "EM1_POR_003"
    "EM1_POR_004"
    "EM1_POR_005"
    "EM1_POR_006"
    "EM1_QUI_001"
    "EM1_QUI_002"
    "EM1_QUI_003"
    "EM2_BIO_001"
    "EM2_BIO_002"
    "EM2_FIS_001"
    "EM2_FIS_002"
    "EM2_MAT_001"
    "EM2_MAT_002"
    "EM2_MAT_003"
    "EM2_MAT_004"
    "EM2_MAT_005"
    "EM2_MAT_006"
    "EM2_MAT_007"
    "EM2_MAT_008"
    "EM2_POR_001"
    "EM2_POR_002"
    "EM2_POR_003"
    "EM2_POR_004"
    "EM2_POR_005"
    "EM2_POR_006"
    "EM2_QUI_001"
    "EM2_QUI_002"
)

total=${#questoes_en[@]}
count=0
sucessos=0
erros=0
pulados=0

# Criar arquivo de log
LOG_FILE="migracao_firebase_$(date +%Y%m%d_%H%M%S).log"
echo "📝 Log salvo em: ${LOG_FILE}"
echo ""

# ===== CONFIRMAÇÃO DO USUÁRIO =====
echo -e "${YELLOW}⚠️  ATENÇÃO: Este script irá modificar ${total} questões no Firebase!${NC}"
echo ""
read -p "Deseja continuar? (sim/não): " confirmacao

if [[ "$confirmacao" != "sim" ]]; then
    echo -e "${RED}❌ Operação cancelada pelo usuário${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}🚀 Iniciando migração...${NC}"
echo ""

# ===== FUNÇÃO DE MIGRAÇÃO (BASH PURO) =====
migrar_questao() {
    local questao_id=$1
    local index=$2
    
    echo -e "${BLUE}[$index/$total]${NC} Processando: ${questao_id}" | tee -a "$LOG_FILE"
    
    # 1. Buscar questão atual
    local response=$(curl -s "${FIREBASE_URL}/${questao_id}")
    
    # 2. Verificar se questão existe
    if echo "$response" | grep -q '"error"'; then
        echo -e "   ${RED}❌ Questão não encontrada no Firebase${NC}" | tee -a "$LOG_FILE"
        return 1
    fi
    
    # 3. Verificar se tem campo 'options' (EN)
    if ! echo "$response" | grep -q '"options"'; then
        echo -e "   ${YELLOW}⚠️  Já em PT ou sem campo 'options', pulando...${NC}" | tee -a "$LOG_FILE"
        return 2
    fi
    
    # 4. Extrair dados usando jq
    local options_json=$(echo "$response" | jq -r '.fields.options.arrayValue.values')
    local question_text=$(echo "$response" | jq -r '.fields.question.stringValue // empty')
    local correct_answer=$(echo "$response" | jq -r '.fields.correct_answer.integerValue // 0')
    
    # 5. Validar dados extraídos
    if [ -z "$question_text" ]; then
        echo -e "   ${RED}❌ Enunciado vazio${NC}" | tee -a "$LOG_FILE"
        return 1
    fi
    
    local num_options=$(echo "$options_json" | jq 'length')
    if [ "$num_options" != "4" ]; then
        echo -e "   ${YELLOW}⚠️  Questão tem ${num_options} alternativas (deveria ser 4)${NC}" | tee -a "$LOG_FILE"
    fi
    
    # 6. Construir JSON para alternativas (converter array de objetos)
    local alternativas_json=$(echo "$options_json" | jq '[.[] | {stringValue: .stringValue}]')
    
    # 7. Criar payload PT
    local payload=$(cat <<EOF
{
  "fields": {
    "alternativas": {
      "arrayValue": {
        "values": ${alternativas_json}
      }
    },
    "enunciado": {
      "stringValue": "${question_text}"
    },
    "resposta_correta": {
      "integerValue": ${correct_answer}
    }
  }
}
EOF
)
    
    # 8. Enviar PATCH para Firebase
    local result=$(curl -s -X PATCH \
        "${FIREBASE_URL}/${questao_id}?updateMask.fieldPaths=alternativas&updateMask.fieldPaths=enunciado&updateMask.fieldPaths=resposta_correta" \
        -H "Content-Type: application/json" \
        -d "$payload")
    
    # 9. Verificar resultado
    if echo "$result" | grep -q '"name"'; then
        # Sucesso - Firebase retorna o documento atualizado
        local enunciado_curto=$(echo "$question_text" | cut -c1-50)
        echo -e "   ${GREEN}✅ Migrado com sucesso${NC}" | tee -a "$LOG_FILE"
        echo "      Enunciado: ${enunciado_curto}..." | tee -a "$LOG_FILE"
        echo "      Alternativas: ${num_options}" | tee -a "$LOG_FILE"
        echo "      Resposta: ${correct_answer}" | tee -a "$LOG_FILE"
        return 0
    else
        # Erro
        echo -e "   ${RED}❌ Erro ao migrar${NC}" | tee -a "$LOG_FILE"
        echo "      Response: $result" | tee -a "$LOG_FILE"
        return 1
    fi
}

# ===== LOOP DE MIGRAÇÃO =====
for questao_id in "${questoes_en[@]}"; do
    count=$((count + 1))
    
    migrar_questao "$questao_id" "$count"
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        sucessos=$((sucessos + 1))
    elif [ $exit_code -eq 2 ]; then
        pulados=$((pulados + 1))
    else
        erros=$((erros + 1))
    fi
    
    echo "" | tee -a "$LOG_FILE"
    
    # Rate limit: aguardar 1 segundo entre requisições
    if [ $count -lt $total ]; then
        sleep 1
    fi
done

# ===== RELATÓRIO FINAL =====
echo "" | tee -a "$LOG_FILE"
echo -e "${BLUE}════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
echo -e "${BLUE}📊 RESULTADO DA MIGRAÇÃO${NC}" | tee -a "$LOG_FILE"
echo -e "${BLUE}════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo -e "${GREEN}✅ Sucessos: ${sucessos}${NC}" | tee -a "$LOG_FILE"
echo -e "${YELLOW}⚠️  Pulados: ${pulados}${NC}" | tee -a "$LOG_FILE"
echo -e "${RED}❌ Erros: ${erros}${NC}" | tee -a "$LOG_FILE"
echo -e "${BLUE}📊 Total: ${total}${NC}" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

if [ $erros -eq 0 ]; then
    echo -e "${GREEN}🎉 MIGRAÇÃO CONCLUÍDA COM SUCESSO!${NC}" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    echo "✅ Todas as questões foram processadas" | tee -a "$LOG_FILE"
    echo "✅ Campos PT criados (alternativas, enunciado, resposta_correta)" | tee -a "$LOG_FILE"
    echo "✅ Campos EN mantidos (options, question, correct_answer)" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    echo -e "${YELLOW}📋 PRÓXIMOS PASSOS:${NC}" | tee -a "$LOG_FILE"
    echo "1. Validar questões no Firebase Console" | tee -a "$LOG_FILE"
    echo "2. Testar app (flutter run)" | tee -a "$LOG_FILE"
    echo "3. Verificar se questões aparecem corretamente" | tee -a "$LOG_FILE"
    echo "4. (Opcional) Remover campos EN antigos" | tee -a "$LOG_FILE"
else
    echo -e "${RED}⚠️  MIGRAÇÃO CONCLUÍDA COM ERROS${NC}" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    echo "Verifique o log para detalhes: ${LOG_FILE}" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    echo -e "${YELLOW}📋 AÇÕES RECOMENDADAS:${NC}" | tee -a "$LOG_FILE"
    echo "1. Revisar erros no log" | tee -a "$LOG_FILE"
    echo "2. Verificar regras Firebase (allow write?)" | tee -a "$LOG_FILE"
    echo "3. Executar novamente para questões com erro" | tee -a "$LOG_FILE"
fi

echo "" | tee -a "$LOG_FILE"
echo "📝 Log completo salvo em: ${LOG_FILE}" | tee -a "$LOG_FILE"
echo ""

exit 0
#!/bin/bash
# migrate_firebase_40_questoes_bash_puro.sh
# Script 100% BASH para migrar 40 questões EN → PT no Firebase
# Versão: 2.0 - BASH PURO (sem Python)
# Data: 29 de outubro de 2025

set -e  # Parar em caso de erro

# ===== CONFIGURAÇÃO =====
FIREBASE_PROJECT="studyquest-app-banco"
FIREBASE_URL="https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT}/databases/(default)/documents/questions"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}🔄 MIGRAÇÃO FIREBASE - 40 QUESTÕES EN → PT${NC}"
echo -e "${BLUE}   100% BASH PURO (sem Python)${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""
echo "📋 Projeto: ${FIREBASE_PROJECT}"
echo "🎯 Objetivo: Padronizar nomenclatura PT"
echo "📊 Total: 40 questões"
echo ""

# ===== VERIFICAR DEPENDÊNCIAS =====
echo -e "${YELLOW}🔍 Verificando dependências...${NC}"

if ! command -v curl &> /dev/null; then
    echo -e "${RED}❌ curl não encontrado. Instale: brew install curl${NC}"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo -e "${RED}❌ jq não encontrado. Instale: brew install jq${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Dependências OK (curl + jq)${NC}"
echo ""

# ===== LISTA DAS 40 QUESTÕES EN =====
questoes_en=(
    "EM1_BIO_001"
    "EM1_BIO_002"
    "EM1_BIO_003"
    "EM1_MAT_001"
    "EM1_MAT_002"
    "EM1_MAT_003"
    "EM1_MAT_004"
    "EM1_MAT_005"
    "EM1_MAT_006"
    "EM1_MAT_007"
    "EM1_MAT_008"
    "EM1_POR_001"
    "EM1_POR_002"
    "EM1_POR_003"
    "EM1_POR_004"
    "EM1_POR_005"
    "EM1_POR_006"
    "EM1_QUI_001"
    "EM1_QUI_002"
    "EM1_QUI_003"
    "EM2_BIO_001"
    "EM2_BIO_002"
    "EM2_FIS_001"
    "EM2_FIS_002"
    "EM2_MAT_001"
    "EM2_MAT_002"
    "EM2_MAT_003"
    "EM2_MAT_004"
    "EM2_MAT_005"
    "EM2_MAT_006"
    "EM2_MAT_007"
    "EM2_MAT_008"
    "EM2_POR_001"
    "EM2_POR_002"
    "EM2_POR_003"
    "EM2_POR_004"
    "EM2_POR_005"
    "EM2_POR_006"
    "EM2_QUI_001"
    "EM2_QUI_002"
)

total=${#questoes_en[@]}
count=0
sucessos=0
erros=0
pulados=0

# Criar arquivo de log
LOG_FILE="migracao_firebase_$(date +%Y%m%d_%H%M%S).log"
echo "📝 Log salvo em: ${LOG_FILE}"
echo ""

# ===== CONFIRMAÇÃO DO USUÁRIO =====
echo -e "${YELLOW}⚠️  ATENÇÃO: Este script irá modificar ${total} questões no Firebase!${NC}"
echo ""
read -p "Deseja continuar? (sim/não): " confirmacao

if [[ "$confirmacao" != "sim" ]]; then
    echo -e "${RED}❌ Operação cancelada pelo usuário${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}🚀 Iniciando migração...${NC}"
echo ""

# ===== FUNÇÃO DE MIGRAÇÃO (BASH PURO) =====
migrar_questao() {
    local questao_id=$1
    local index=$2
    
    echo -e "${BLUE}[$index/$total]${NC} Processando: ${questao_id}" | tee -a "$LOG_FILE"
    
    # 1. Buscar questão atual
    local response=$(curl -s "${FIREBASE_URL}/${questao_id}")
    
    # 2. Verificar se questão existe
    if echo "$response" | grep -q '"error"'; then
        echo -e "   ${RED}❌ Questão não encontrada no Firebase${NC}" | tee -a "$LOG_FILE"
        return 1
    fi
    
    # 3. Verificar se tem campo 'options' (EN)
    if ! echo "$response" | grep -q '"options"'; then
        echo -e "   ${YELLOW}⚠️  Já em PT ou sem campo 'options', pulando...${NC}" | tee -a "$LOG_FILE"
        return 2
    fi
    
    # 4. Extrair dados usando jq
    local options_json=$(echo "$response" | jq -r '.fields.options.arrayValue.values')
    local question_text=$(echo "$response" | jq -r '.fields.question.stringValue // empty')
    local correct_answer=$(echo "$response" | jq -r '.fields.correct_answer.integerValue // 0')
    
    # 5. Validar dados extraídos
    if [ -z "$question_text" ]; then
        echo -e "   ${RED}❌ Enunciado vazio${NC}" | tee -a "$LOG_FILE"
        return 1
    fi
    
    local num_options=$(echo "$options_json" | jq 'length')
    if [ "$num_options" != "4" ]; then
        echo -e "   ${YELLOW}⚠️  Questão tem ${num_options} alternativas (deveria ser 4)${NC}" | tee -a "$LOG_FILE"
    fi
    
    # 6. Construir JSON para alternativas (converter array de objetos)
    local alternativas_json=$(echo "$options_json" | jq '[.[] | {stringValue: .stringValue}]')
    
    # 7. Criar payload PT
    local payload=$(cat <<EOF
{
  "fields": {
    "alternativas": {
      "arrayValue": {
        "values": ${alternativas_json}
      }
    },
    "enunciado": {
      "stringValue": "${question_text}"
    },
    "resposta_correta": {
      "integerValue": ${correct_answer}
    }
  }
}
EOF
)
    
    # 8. Enviar PATCH para Firebase
    local result=$(curl -s -X PATCH \
        "${FIREBASE_URL}/${questao_id}?updateMask.fieldPaths=alternativas&updateMask.fieldPaths=enunciado&updateMask.fieldPaths=resposta_correta" \
        -H "Content-Type: application/json" \
        -d "$payload")
    
    # 9. Verificar resultado
    if echo "$result" | grep -q '"name"'; then
        # Sucesso - Firebase retorna o documento atualizado
        local enunciado_curto=$(echo "$question_text" | cut -c1-50)
        echo -e "   ${GREEN}✅ Migrado com sucesso${NC}" | tee -a "$LOG_FILE"
        echo "      Enunciado: ${enunciado_curto}..." | tee -a "$LOG_FILE"
        echo "      Alternativas: ${num_options}" | tee -a "$LOG_FILE"
        echo "      Resposta: ${correct_answer}" | tee -a "$LOG_FILE"
        return 0
    else
        # Erro
        echo -e "   ${RED}❌ Erro ao migrar${NC}" | tee -a "$LOG_FILE"
        echo "      Response: $result" | tee -a "$LOG_FILE"
        return 1
    fi
}

# ===== LOOP DE MIGRAÇÃO =====
for questao_id in "${questoes_en[@]}"; do
    count=$((count + 1))
    
    migrar_questao "$questao_id" "$count"
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        sucessos=$((sucessos + 1))
    elif [ $exit_code -eq 2 ]; then
        pulados=$((pulados + 1))
    else
        erros=$((erros + 1))
    fi
    
    echo "" | tee -a "$LOG_FILE"
    
    # Rate limit: aguardar 1 segundo entre requisições
    if [ $count -lt $total ]; then
        sleep 1
    fi
done

# ===== RELATÓRIO FINAL =====
echo "" | tee -a "$LOG_FILE"
echo -e "${BLUE}════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
echo -e "${BLUE}📊 RESULTADO DA MIGRAÇÃO${NC}" | tee -a "$LOG_FILE"
echo -e "${BLUE}════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo -e "${GREEN}✅ Sucessos: ${sucessos}${NC}" | tee -a "$LOG_FILE"
echo -e "${YELLOW}⚠️  Pulados: ${pulados}${NC}" | tee -a "$LOG_FILE"
echo -e "${RED}❌ Erros: ${erros}${NC}" | tee -a "$LOG_FILE"
echo -e "${BLUE}📊 Total: ${total}${NC}" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

if [ $erros -eq 0 ]; then
    echo -e "${GREEN}🎉 MIGRAÇÃO CONCLUÍDA COM SUCESSO!${NC}" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    echo "✅ Todas as questões foram processadas" | tee -a "$LOG_FILE"
    echo "✅ Campos PT criados (alternativas, enunciado, resposta_correta)" | tee -a "$LOG_FILE"
    echo "✅ Campos EN mantidos (options, question, correct_answer)" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    echo -e "${YELLOW}📋 PRÓXIMOS PASSOS:${NC}" | tee -a "$LOG_FILE"
    echo "1. Validar questões no Firebase Console" | tee -a "$LOG_FILE"
    echo "2. Testar app (flutter run)" | tee -a "$LOG_FILE"
    echo "3. Verificar se questões aparecem corretamente" | tee -a "$LOG_FILE"
    echo "4. (Opcional) Remover campos EN antigos" | tee -a "$LOG_FILE"
else
    echo -e "${RED}⚠️  MIGRAÇÃO CONCLUÍDA COM ERROS${NC}" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    echo "Verifique o log para detalhes: ${LOG_FILE}" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    echo -e "${YELLOW}📋 AÇÕES RECOMENDADAS:${NC}" | tee -a "$LOG_FILE"
    echo "1. Revisar erros no log" | tee -a "$LOG_FILE"
    echo "2. Verificar regras Firebase (allow write?)" | tee -a "$LOG_FILE"
    echo "3. Executar novamente para questões com erro" | tee -a "$LOG_FILE"
fi

echo "" | tee -a "$LOG_FILE"
echo "📝 Log completo salvo em: ${LOG_FILE}" | tee -a "$LOG_FILE"
echo ""

exit 0

