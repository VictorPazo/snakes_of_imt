# Setup — rodando o OphidIA em outra máquina

Passo a passo do clone até a primeira identificação. O projeto tem duas metades que
sobem separadamente: o **app Flutter** e o **servidor de inferência FastAPI**. As duas
precisam estar no ar ao mesmo tempo, e o app precisa saber o IP do servidor.

## Pré-requisitos

| Ferramenta | Versão | Observação |
|---|---|---|
| Flutter + Android SDK | 3.41.9 (testada) | `flutter doctor` deve passar |
| Python | 3.12 | no Windows, os comandos abaixo usam `py -3.12` |
| Dispositivo Android | físico ou emulador | o físico precisa estar no mesmo Wi-Fi do servidor |

> As constraints do `pubspec.yaml` foram afrouxadas para caber no Flutter 3.41.9
> (`shimmer ^3.0.0`, `flutter_native_splash ^2.4.0`). Em um Flutter mais novo elas
> continuam resolvendo, só não pegam as versões mais recentes desses dois pacotes.

## 1. Dependências do app

```bash
flutter pub get
```

## 2. Dependências do servidor de inferência

```bash
cd lib/models
pip install -r requirements.txt
```

Isso instala a build de **CPU** do PyTorch, que funciona normalmente (só mais lenta:
~83 ms por imagem contra ~10 ms em GPU). Para GPU:

```bash
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu130
```

## 3. Colocar os pesos do modelo

**Este passo não tem como ser automatizado e é o que mais trava gente nova no projeto.**

O arquivo `lib/models/best_model.pth` tem 107 MB — acima do limite de 100 MB por arquivo
do GitHub. Por isso `*.pth` está no `.gitignore` e **o modelo não vem no clone**.

Copie-o à mão para `lib/models/best_model.pth`. Na máquina de treino original ele está em
`D:\treino_v2\checkpoints\best_model.pth`. Sem esse arquivo o `uvicorn` nem sobe.

O `lib/models/classes.json` (246 espécies) **está** versionado e já vem no clone — mas ele
e o `.pth` são um par: os dois têm que vir do mesmo treino, senão as predições saem
silenciosamente trocadas.

## 4. Subir o servidor

```bash
cd lib/models
py -3.12 -m uvicorn main:app --host 0.0.0.0 --port 8000
```

O `--host 0.0.0.0` não é opcional — sem ele o servidor só aceita conexões do próprio PC e
o celular não alcança. Na primeira execução o Windows pode pedir liberação no firewall:
aceite para rede **privada**.

Para conferir se subiu, do próprio PC: <http://localhost:8000/docs>

## 5. Apontar o app para o servidor

Edite `baseUrl` em `lib/services/agent_service.dart`:

- **Celular físico** — o IP da máquina na rede local (`ipconfig` no Windows,
  `ip addr` no Linux). Ex.: `http://192.168.0.2:8000`
- **Emulador Android** — obrigatoriamente `http://10.0.2.2:8000`. O IP da LAN **não**
  funciona no emulador; `10.0.2.2` é como ele enxerga o PC hospedeiro.

## 6. Rodar o app

```bash
flutter run
```

## Opcional — pipeline de povoamento do banco

Só é necessário para inserir novas espécies na tabela `snakes` do Supabase. O passo a
passo completo está em [`lib/scripts/README.md`](lib/scripts/README.md).

```bash
cd lib/scripts
pip install -r requirements.txt
```

Exige um arquivo `.env` (também **não versionado**) nesta pasta:

```
SUPABASE_URL=...
SUPABASE_SERVICE_KEY=...
```

A `service_role` key sai em *Project Settings > API > service_role secret* no painel do
Supabase.

## O que NÃO precisa ser configurado

- **Supabase do app** — URL e anon key estão fixos em `lib/main.dart`.
- **Google Maps** — a chave já está no `android/app/src/main/AndroidManifest.xml`.

## Resumo: o que não vem no clone

| Arquivo | Como obter |
|---|---|
| `lib/models/best_model.pth` | copiar da máquina de treino (107 MB, fora do git) |
| `lib/scripts/.env` | criar à mão com as credenciais do Supabase |
