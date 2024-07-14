# Terraform GCP Infrastructure

Este projeto contém um conjunto de arquivos de configuração do Terraform para provisionar uma infraestrutura básica no Google Cloud Platform (GCP). A infraestrutura inclui uma rede VPC, duas instâncias de VM, e um balanceador de carga HTTP(S).

## Estrutura do Projeto

- `main.tf`: Define os recursos principais, incluindo a VPC, sub-redes, instâncias de VM, regras de firewall, e o balanceador de carga.
- `variables.tf`: Define as variáveis de entrada usadas no projeto, como `project_id`, `region`, e `credentials_file_path`.
- `outputs.tf`: Define as saídas que mostram os IPs das instâncias de VM e do balanceador de carga.

## Justificativa das Escolhas de Configuração

### Tipo de Instância

- **e2-micro**: Escolhemos a instância `e2-micro` por ser uma opção econômica, adequada para cargas de trabalho leves, como este desafio. As instâncias `e2-micro` oferecem uma boa relação custo-benefício para projetos de teste e desenvolvimento.

### Sub-redes

- **subnet1 (192.168.1.0/24 em us-central1)**: Esta sub-rede está localizada na região `us-central1` para garantir baixa latência e alta disponibilidade para usuários situados na América do Norte. Esta configuração oferece uma faixa de endereços IP privada, essencial para a comunicação interna entre recursos na VPC.
- **subnet2 (10.152.0.0/24 em us-east1)**: A segunda sub-rede está situada em `us-east1`, garantindo redundância geográfica. Em caso de falha na região `us-central1`, os recursos em `us-east1` ainda estarão operacionais, melhorando a resiliência da infraestrutura.

### Regras de Firewall

- **Tráfego HTTP (porta 80)**: Configuramos regras de firewall para permitir o tráfego HTTP nas portas 80 tanto para as VMs quanto para o balanceador de carga. Essa configuração é crucial para o acesso externo aos servidores web Apache, garantindo que os usuários possam acessar os sites hospedados nas instâncias.
- **Segurança**: Embora tenhamos aberto o tráfego HTTP para todas as fontes (`0.0.0.0/0`), em um ambiente de produção, seria recomendado restringir essas regras para endereços IP específicos ou utilizar outras medidas de segurança, como firewalls de aplicação web.
