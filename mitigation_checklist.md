# 🛡️ Checklist de Mitigação contra Ataques de Força Bruta

## Visão Geral
Esta lista de verificação fornece medidas práticas para proteger sistemas contra ataques de força bruta. Use-a como guia de implementação em ambientes de produção.

---

## 1️⃣ Políticas de Senha

### Requisitos Mínimos
- [ ] Comprimento mínimo de 12 caracteres
- [ ] Combinação obrigatória de:
  - [ ] Letras maiúsculas (A-Z)
  - [ ] Letras minúsculas (a-z)
  - [ ] Números (0-9)
  - [ ] Caracteres especiais (!@#$%^&*)
- [ ] Verificação contra dicionário de senhas comuns
- [ ] Histórico de senhas (mínimo 5 senhas anteriores)
- [ ] Expiração periódica (recomendado: 90 dias)
- [ ] Proibir informações pessoais óbvias (nome, data de nascimento)

### Implementação
```bash
# Exemplo no Linux - /etc/pam.d/common-password
password requisite pam_pwquality.so retry=3 minlen=12 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1
```

---

## 2️⃣ Limitação de Tentativas (Rate Limiting)

### SSH/FTP
- [ ] Instalar e configurar Fail2Ban
- [ ] Definir número máximo de tentativas: **3-5**
- [ ] Tempo de bloqueio: **30-60 minutos**
- [ ] Janela de observação: **10 minutos**

**Configuração Fail2Ban:**
```ini
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
```

### Aplicações Web
- [ ] Implementar throttling progressivo
- [ ] CAPTCHA após 3 tentativas falhas
- [ ] Bloqueio temporário após 5 tentativas
- [ ] Log de todas as tentativas

**Exemplo de implementação:**
```python
from time import sleep

def login_attempt(username, password, failed_count):
    if failed_count >= 3:
        # Delay exponencial
        sleep(2 ** failed_count)
    
    if failed_count >= 5:
        return "Account temporarily locked"
    
    # Validar credenciais...
```

---

## 3️⃣ Autenticação Multifator (MFA)

### Implementação Obrigatória Para:
- [ ] Contas administrativas
- [ ] Acesso remoto (VPN, SSH)
- [ ] Sistemas críticos
- [ ] Após redefinição de senha

### Métodos Recomendados:
1. **Aplicativos Autenticadores** (mais seguro)
   - Google Authenticator
   - Microsoft Authenticator
   - Authy

2. **SMS/Email** (menos seguro, mas melhor que nada)

3. **Chaves de Segurança Física** (mais seguro)
   - YubiKey
   - Titan Security Key

**Teste de implementação:**
```bash
# Habilitar MFA no SSH (Google Authenticator)
sudo apt install libpam-google-authenticator
google-authenticator
```

---

## 4️⃣ Monitoramento e Alertas

### Logs a Monitorar
- [ ] Tentativas de login falhas
- [ ] Logins bem-sucedidos fora do horário
- [ ] Múltiplas tentativas do mesmo IP
- [ ] Tentativas de usuários inexistentes
- [ ] Mudanças de senha

### Ferramentas
- [ ] Configurar SIEM (Security Information and Event Management)
- [ ] Alertas em tempo real
- [ ] Dashboard de segurança
- [ ] Relatórios periódicos

**Comandos úteis:**
```bash
# Monitorar tentativas SSH
tail -f /var/log/auth.log | grep "Failed password"

# Listar IPs com mais tentativas falhas
grep "Failed password" /var/log/auth.log | awk '{print $(NF-3)}' | sort | uniq -c | sort -rn | head

# Verificar últimos logins
last -a | head -20
```

---

## 5️⃣ Hardening de Serviços

### SSH
- [ ] Desabilitar autenticação por senha (usar chaves SSH)
- [ ] Mudar porta padrão (22 → outra)
- [ ] Desabilitar login root
- [ ] Permitir apenas usuários específicos
- [ ] Usar protocolo SSH v2

**Configuração /etc/ssh/sshd_config:**
```
Port 2222
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AllowUsers user1 user2
Protocol 2
MaxAuthTries 3
```

### FTP
- [ ] Substituir FTP por SFTP/FTPS
- [ ] Desabilitar login anônimo
- [ ] Usar chroot jail
- [ ] Limitar usuários permitidos

### SMB
- [ ] Desabilitar SMBv1
- [ ] Usar autenticação forte
- [ ] Restringir compartilhamentos
- [ ] Configurar firewall

### Aplicações Web
- [ ] HTTPS obrigatório
- [ ] Security headers (CSP, HSTS)
- [ ] WAF (Web Application Firewall)
- [ ] Sanitização de inputs

---

## 6️⃣ Controle de Acesso por IP

### Listas Brancas (Whitelist)
- [ ] VPN corporativa
- [ ] IPs de escritórios
- [ ] Infraestrutura confiável

### Bloqueio Geográfico
- [ ] Bloquear países não autorizados
- [ ] Usar GeoIP filtering

**Implementação com iptables:**
```bash
# Permitir apenas IPs específicos no SSH
iptables -A INPUT -p tcp --dport 22 -s 192.168.1.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j DROP

# Salvar regras
iptables-save > /etc/iptables/rules.v4
```

---

## 7️⃣ Gestão de Contas

### Boas Práticas
- [ ] Remover contas padrão e não utilizadas
- [ ] Renomear conta "admin"
- [ ] Auditar contas periodicamente
- [ ] Implementar princípio do menor privilégio
- [ ] Revisar permissões trimestralmente

**Comandos de auditoria:**
```bash
# Listar todos os usuários
cat /etc/passwd

# Verificar contas sem senha
sudo awk -F: '($2 == "") {print $1}' /etc/shadow

# Listar usuários com UID 0 (root)
awk -F: '($3 == "0") {print}' /etc/passwd

# Usuários inativos
lastlog -b 90
```

---

## 8️⃣ Resposta a Incidentes

### Plano de Ação
- [ ] Documentar procedimento de resposta
- [ ] Definir equipe responsável
- [ ] Contatos de emergência
- [ ] Processo de escalação

### Em Caso de Ataque Detectado:
1. **Identificar** fonte do ataque
2. **Bloquear** IP/rede atacante
3. **Verificar** se houve comprometimento
4. **Documentar** incidente
5. **Reforçar** medidas de segurança
6. **Comunicar** stakeholders

**Template de resposta:**
```bash
#!/bin/bash
# Script de resposta a ataque de força bruta

ATTACKER_IP=$1
LOG_FILE="/var/log/security_incident_$(date +%Y%m%d_%H%M%S).log"

echo "[$(date)] Incidente de segurança detectado" | tee -a $LOG_FILE
echo "IP Atacante: $ATTACKER_IP" | tee -a $LOG_FILE

# Bloquear IP
iptables -A INPUT -s $ATTACKER_IP -j DROP
echo "IP $ATTACKER_IP bloqueado" | tee -a $LOG_FILE

# Verificar tentativas
grep $ATTACKER_IP /var/log/auth.log | tee -a $LOG_FILE

# Alertar administrador
mail -s "Ataque de Força Bruta Detectado" admin@empresa.com < $LOG_FILE
```

---

## 9️⃣ Testes Periódicos

### Auditoria de Segurança
- [ ] Pentests trimestrais
- [ ] Scans de vulnerabilidades mensais
- [ ] Revisão de logs semanais
- [ ] Simulações de ataque

### Ferramentas de Teste
- [ ] Nmap (reconhecimento)
- [ ] Medusa/Hydra (força bruta)
- [ ] Nikto (web)
- [ ] OpenVAS (vulnerabilidades)

---

## 🔟 Educação e Conscientização

### Treinamento de Usuários
- [ ] Importância de senhas fortes
- [ ] Reconhecimento de phishing
- [ ] Uso de gerenciadores de senhas
- [ ] Reporte de atividades suspeitas

### Cultura de Segurança
- [ ] Políticas claras e acessíveis
- [ ] Campanhas de conscientização
- [ ] Simulações de ataques
- [ ] Recompensas por boas práticas

---

## 📊 Métricas de Acompanhamento

### KPIs de Segurança
- [ ] Número de tentativas de força bruta/dia
- [ ] Taxa de bloqueios automáticos
- [ ] Tempo médio de detecção
- [ ] Conformidade com políticas de senha
- [ ] % de usuários com MFA habilitado

---

## ✅ Status de Implementação

| Medida | Status | Prioridade | Data Prevista |
|--------|--------|------------|---------------|
| Políticas de Senha | ⬜ | Alta | ___/___/___ |
| Fail2Ban | ⬜ | Alta | ___/___/___ |
| MFA | ⬜ | Alta | ___/___/___ |
| Monitoramento | ⬜ | Média | ___/___/___ |
| Hardening SSH | ⬜ | Alta | ___/___/___ |
| Bloqueio Geográfico | ⬜ | Baixa | ___/___/___ |
| Auditoria de Contas | ⬜ | Média | ___/___/___ |
| Plano de Resposta | ⬜ | Alta | ___/___/___ |
| Testes Periódicos | ⬜ | Média | ___/___/___ |
| Treinamento | ⬜ | Média | ___/___/___ |

**Legenda:** ⬜ Pendente | 🔄 Em Progresso | ✅ Concluído

---

## 📚 Recursos Adicionais

- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [NIST Digital Identity Guidelines](https://pages.nist.gov/800-63-3/)
- [CIS Controls](https://www.cisecurity.org/controls)
- [Fail2Ban Documentation](https://www.fail2ban.org/)

---

**Última atualização:** [Data]  
**Responsável:** [Nome]  
**Próxima revisão:** [Data]
