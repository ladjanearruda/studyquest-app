#!/bin/bash
set -e
FIREBASE_URL="https://firestore.googleapis.com/v1/projects/studyquest-app-banco/databases/(default)/documents/questions"

questoes_en=(
    "EM1_POR_001" "EM1_POR_002" "EM1_POR_003" "EM1_POR_004"
    "EM1_POR_005" "EM1_POR_006"
    "EM1_QUI_001" "EM1_QUI_002" "EM1_QUI_003"
    "EM2_BIO_001" "EM2_BIO_002"
    "EM2_FIS_001" "EM2_FIS_002"
    "EM2_MAT_001" "EM2_MAT_002" "EM2_MAT_003" "EM2_MAT_004"
    "EM2_MAT_005" "EM2_MAT_006" "EM2_MAT_007" "EM2_MAT_008"
    "EM2_POR_001" "EM2_POR_002" "EM2_POR_003" "EM2_POR_004"
    "EM2_POR_005" "EM2_POR_006"
    "EM2_QUI_001" "EM2_QUI_002"
)

echo "🔄 Migrando ${#questoes_en[@]} questões restantes (V3 - JSON direto)"
read -p "Continuar? (sim): " c
[[ "$c" != "sim" ]] && exit 0

count=0
ok=0
for q in "${questoes_en[@]}"; do
    count=$((count + 1))
    echo "[$count/${#questoes_en[@]}] $q"
    
    resp=$(curl -s "${FIREBASE_URL}/${q}")
    
    # Verificar se tem 'options'
    echo "$resp" | jq -e '.fields.options' > /dev/null 2>&1 || { echo "  ⚠️ Pulado"; continue; }
    
    # ✅ TRANSFORMAÇÃO JSON DIRETA (SEM TOCAR NAS STRINGS!)
    payload=$(echo "$resp" | jq '{
        fields: {
            alternativas: .fields.options,
            enunciado: .fields.question,
            resposta_correta: .fields.correct_answer
        }
    }')
    
    # Enviar
    result=$(curl -s -X PATCH \
        "${FIREBASE_URL}/${q}?updateMask.fieldPaths=alternativas&updateMask.fieldPaths=enunciado&updateMask.fieldPaths=resposta_correta" \
        -H "Content-Type: application/json" \
        -d "$payload")
    
    if echo "$result" | jq -e '.name' > /dev/null 2>&1; then
        echo "  ✅ OK"
        ok=$((ok + 1))
    else
        echo "  ❌ Erro: $(echo "$result" | jq -r '.error.message')"
    fi
    
    sleep 1
done

echo ""
echo "🎉 Fim! Sucessos: $ok/${#questoes_en[@]}"
echo "Total geral: $((11 + ok))/40 questões migradas"
