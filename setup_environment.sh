#!/bin/bash

# Script de Configuração do Ambiente de Teste
# Projeto: Brute Force com Medusa e Kali Linux
# Autor: [Seu Nome]

echo "================================================"
echo "  Configuração do Ambiente de Teste"
echo "  Brute Force Security Audit"
echo "================================================"
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}[!] Este script precisa ser executado como root${NC}"
    echo "    Use: sudo ./setup_environment.sh"
    exit 1
fi

echo -e "${GREEN}[+] Atualizando sistema...${NC}"
apt update -qq && apt upgrade -y -qq

echo -e "${GREEN}[+] Verificando ferramentas necessárias...${NC}"

# Lista de ferramentas
TOOLS=("medusa" "nmap" "hydra" "smbclient" "enum4linux" "ftp")

for tool in "${TOOLS[@]}"; do
    if command -v $tool &> /dev/null; then
        echo -e "${GREEN}  ✓ $tool está instalado${NC}"
    else
        echo -e "${YELLOW}  → Instalando $tool...${NC}"
        apt install -y $tool -qq
    fi
done

echo ""
echo -e "${GREEN}[+] Criando estrutura de diretórios...${NC}"
mkdir -p wordlists scripts images docs logs

echo -e "${GREEN}[+] Gerando wordlists básicas...${NC}"

# Wordlist para FTP
cat > wordlists/passwords_ftp.txt << 'EOF'
123456
password
admin
root
toor
metasploitable
user
msfadmin
ftp
anonymous
EOF

# Wordlist para Web
cat > wordlists/passwords_web.txt << 'EOF'
password
admin
123456
letmein
welcome
monkey
dragon
master
qwerty
abc123
EOF

# Lista de usuários comuns
cat > wordlists/users_common.txt << 'EOF'
root
admin
user
msfadmin
postgres
service
ftp
guest
www-data
backup
EOF

echo -e "${GREEN}[+] Configurando permissões...${NC}"
chmod +x scripts/*.sh 2>/dev/null
chmod 644 wordlists/*.txt 2>/dev/null

echo ""
echo -e "${GREEN}[+] Testando conectividade com alvo...${NC}"
read -p "Digite o IP da máquina alvo (ex: 192.168.56.20): " TARGET_IP

if ping -c 2 $TARGET_IP &> /dev/null; then
    echo -e "${GREEN}  ✓ Conectividade OK com $TARGET_IP${NC}"
    
    echo -e "${GREEN}[+] Executando scan básico...${NC}"
    nmap -sV -p 21,22,80,139,445 $TARGET_IP -oN logs/initial_scan.txt
    
    echo ""
    echo -e "${GREEN}[+] Serviços detectados:${NC}"
    cat logs/initial_scan.txt | grep "open"
else
    echo -e "${RED}  ✗ Não foi possível conectar ao alvo $TARGET_IP${NC}"
    echo -e "${YELLOW}  → Verifique a configuração de rede${NC}"
fi

echo ""
echo "================================================"
echo -e "${GREEN}  Configuração concluída!${NC}"
echo "================================================"
echo ""
echo "Próximos passos:"
echo "  1. Revisar os arquivos gerados em wordlists/"
echo "  2. Verificar logs/initial_scan.txt"
echo "  3. Executar testes específicos com Medusa"
echo ""
echo "Exemplo de comando:"
echo "  medusa -h $TARGET_IP -u msfadmin -P wordlists/passwords_ftp.txt -M ftp"
echo ""
