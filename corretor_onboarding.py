#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para corrigir todos os update() do onboarding_screen.dart
Substitui padrão manual por copyWith()
"""

import re

def corrigir_update_blocks(conteudo):
    """
    Encontra blocos de update() e substitui por copyWith()
    """
    
    # Padrão regex para capturar blocos de update
    pattern = r'ref\.read\(onboardingProvider\.notifier\)\.update\(\(state\) \{[\s\S]*?final newState = OnboardingData\(\);([\s\S]*?)return newState;[\s\S]*?\}\);'
    
    def substituir_bloco(match):
        bloco_completo = match.group(0)
        corpo = match.group(1)
        
        # Extrair campos sendo atribuídos
        campos_regex = r'newState\.(\w+)\s*=\s*([^;]+);'
        campos = re.findall(campos_regex, corpo)
        
        # Separar campos que vêm do state vs valores novos
        campos_copyWith = []
        
        for nome_campo, valor in campos:
            # Se o valor é 'state.CAMPO', não inclui no copyWith (mantém original)
            if valor.strip() == f'state.{nome_campo}':
                continue
            # Adiciona ao copyWith
            campos_copyWith.append(f'    {nome_campo}: {valor.strip()}')
        
        # Se não tem campos novos, pula (não deveria acontecer, mas por segurança)
        if not campos_copyWith:
            return bloco_completo
        
        # Montar novo código com copyWith
        campos_str = ',\n'.join(campos_copyWith)
        novo_codigo = f'''ref.read(onboardingProvider.notifier).update((state) {{
  return state.copyWith(
{campos_str},
  );
}});'''
        
        return novo_codigo
    
    # Aplicar substituição
    conteudo_corrigido = re.sub(pattern, substituir_bloco, conteudo)
    
    return conteudo_corrigido


def main():
    arquivo_path = 'lib/features/onboarding/screens/onboarding_screen.dart'
    
    print("🔧 Iniciando correção do onboarding_screen.dart...")
    
    # Ler arquivo original
    try:
        with open(arquivo_path, 'r', encoding='utf-8') as f:
            conteudo_original = f.read()
    except FileNotFoundError:
        print(f"❌ Arquivo não encontrado: {arquivo_path}")
        print("Execute este script na raiz do projeto StudyQuest!")
        return
    
    # Fazer backup
    backup_path = arquivo_path + '.backup'
    with open(backup_path, 'w', encoding='utf-8') as f:
        f.write(conteudo_original)
    print(f"✅ Backup criado: {backup_path}")
    
    # Aplicar correções
    conteudo_corrigido = corrigir_update_blocks(conteudo_original)
    
    # Contar quantas substituições foram feitas
    ocorrencias_original = conteudo_original.count('final newState = OnboardingData();')
    ocorrencias_corrigido = conteudo_corrigido.count('final newState = OnboardingData();')
    substituicoes = ocorrencias_original - ocorrencias_corrigido
    
    print(f"📊 Total de blocos corrigidos: {substituicoes}")
    
    # Salvar arquivo corrigido
    with open(arquivo_path, 'w', encoding='utf-8') as f:
        f.write(conteudo_corrigido)
    
    print(f"✅ Arquivo corrigido salvo: {arquivo_path}")
    print("\n🎉 Correção concluída com sucesso!")
    print(f"💡 Se algo der errado, restaure o backup: {backup_path}")


if __name__ == '__main__':
    main()


