#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script V2 - Corretor onboarding_screen.dart
Abordagem linha por linha para capturar todos os casos
"""

def corrigir_arquivo_completo(conteudo):
    """
    Processa o arquivo linha por linha identificando blocos update()
    """
    linhas = conteudo.split('\n')
    novas_linhas = []
    i = 0
    substituicoes = 0
    
    while i < len(linhas):
        linha = linhas[i]
        
        # Detecta início de bloco update
        if 'ref.read(onboardingProvider.notifier).update((state) {' in linha:
            # Capturar indentação
            indent = len(linha) - len(linha.lstrip())
            indent_str = ' ' * indent
            
            # Verificar se próxima linha tem "final newState"
            if i + 1 < len(linhas) and 'final newState = OnboardingData();' in linhas[i + 1]:
                # Encontrou bloco antigo! Processar
                substituicoes += 1
                
                # Pular linha do update e do final newState
                i += 2
                
                # Coletar todas as atribuições
                campos_novos = {}
                while i < len(linhas):
                    linha_atual = linhas[i]
                    
                    # Se chegou no return newState, parar
                    if 'return newState;' in linha_atual:
                        i += 1  # Pular o return
                        # Próxima linha deve ser }); - pular também
                        if i < len(linhas) and '});' in linhas[i]:
                            i += 1
                        break
                    
                    # Capturar atribuição: newState.CAMPO = VALOR;
                    if 'newState.' in linha_atual:
                        # Parse: newState.campo = valor;
                        partes = linha_atual.split('=', 1)
                        if len(partes) == 2:
                            campo = partes[0].strip().replace('newState.', '')
                            valor = partes[1].strip().rstrip(';')
                            
                            # Só adiciona se NÃO for state.campo (ou seja, é um valor novo)
                            if valor.strip() != f'state.{campo}':
                                campos_novos[campo] = valor
                    
                    i += 1
                
                # Gerar novo código com copyWith
                if campos_novos:
                    novas_linhas.append(f"{indent_str}ref.read(onboardingProvider.notifier).update((state) {{")
                    novas_linhas.append(f"{indent_str}  return state.copyWith(")
                    
                    # Adicionar campos
                    campos_lista = list(campos_novos.items())
                    for idx, (campo, valor) in enumerate(campos_lista):
                        virgula = ',' if idx < len(campos_lista) - 1 else ','
                        novas_linhas.append(f"{indent_str}    {campo}: {valor}{virgula}")
                    
                    novas_linhas.append(f"{indent_str}  );")
                    novas_linhas.append(f"{indent_str}}});")
                else:
                    # Sem campos novos, manter estado (não deveria acontecer)
                    novas_linhas.append(f"{indent_str}// AVISO: Bloco sem alterações removido")
                
                continue
        
        # Linha normal, manter
        novas_linhas.append(linha)
        i += 1
    
    return '\n'.join(novas_linhas), substituicoes


def main():
    arquivo_path = 'lib/features/onboarding/screens/onboarding_screen.dart'
    
    print("🔧 Iniciando correção V2 do onboarding_screen.dart...")
    
    # Ler arquivo original
    try:
        with open(arquivo_path, 'r', encoding='utf-8') as f:
            conteudo_original = f.read()
    except FileNotFoundError:
        print(f"❌ Arquivo não encontrado: {arquivo_path}")
        return
    
    # Fazer backup (sobrescreve backup anterior)
    backup_path = arquivo_path + '.backup'
    with open(backup_path, 'w', encoding='utf-8') as f:
        f.write(conteudo_original)
    print(f"✅ Backup atualizado: {backup_path}")
    
    # Aplicar correções
    conteudo_corrigido, substituicoes = corrigir_arquivo_completo(conteudo_original)
    
    print(f"📊 Total de blocos corrigidos: {substituicoes}")
    
    # Salvar arquivo corrigido
    with open(arquivo_path, 'w', encoding='utf-8') as f:
        f.write(conteudo_corrigido)
    
    print(f"✅ Arquivo corrigido salvo: {arquivo_path}")
    print("\n🎉 Correção V2 concluída!")
    print(f"💡 Backup em: {backup_path}")
    
    # Validação
    count_copyWith = conteudo_corrigido.count('state.copyWith')
    count_newState = conteudo_corrigido.count('final newState = OnboardingData();')
    
    print(f"\n📈 Validação:")
    print(f"   copyWith criados: {count_copyWith}")
    print(f"   Blocos antigos restantes: {count_newState}")
    
    if count_newState == 0:
        print("\n✅ SUCESSO: Todos os blocos foram corrigidos!")
    else:
        print(f"\n⚠️  ATENÇÃO: Ainda restam {count_newState} blocos antigos")


if __name__ == '__main__':
    main()

