# 🍊 Zest - App de Descoberta e Gestão de Restaurantes

**Zest** é uma aplicação móvel desenvolvida em **Flutter** para a disciplina de Programação para Dispositivos Móveis, o app conecta clientes a experiências gastronômicas, permitindo a descoberta de restaurantes via Mapa ou Lista, e oferecendo uma experiência completa de gerenciamento para proprietários de restaurantes.

---

## 📱 Funcionalidades Principais

### 🗺️ Para o Usuário (Cliente)
* **Busca Inteligente:** Pesquisa por nome, tags (ex: Sushi, Pizza) e filtro por proximidade.
* **Geolocalização:** Mapa interativo com marcadores personalizados e filtros de "Aberto Agora".
* **Detalhes do Local:** Visualização de cardápio (tags), horários e descrição com visual moderno.
* **Ações Rápidas:** Botões diretos para iniciar conversa no **WhatsApp** ou traçar rota no **Google Maps**.

### 🏢 Para o Dono (Gestão)
* **CRUD Completo:** Criar, Ler, Atualizar e Deletar restaurantes.
* **Cadastro Otimizado:** Upload de logo, máscaras de formatação (Telefone/Horário) e busca de endereço por GPS ou CEP.
* **Gestão de Conta:** Edição de perfil (Avatar/Nome), alteração de credenciais e exclusão de conta com limpeza de dados em cascata.

---

## 🛠️ Tecnologias Utilizadas

* **Front-end:** Flutter (Dart).
* **Arquitetura:** MVC (Model-View-Controller) com **GetX** para Gerência de Estado e Injeção de Dependências.
* **Back-end:** Firebase Authentication (Login/Registro) e Cloud Firestore (Banco de Dados NoSQL).
* **Integrações:**
    * `Maps_flutter`: Mapas nativos.
    * `geolocator` & `geocoding`: Serviços de localização.
    * `url_launcher`: Integração com apps externos.
    * `image_picker`: Captura e otimização de imagens.

---

## 📸 Como Rodar o Projeto

1.  **Clone o repositório:**
    ```bash
    git clone [https://github.com/PietroDev-01/Zest_Flutter](https://github.com/PietroDev-01/Zest_Flutter)
    ```

2.  **Instale as dependências:**
    ```bash
    flutter pub get
    ```

3.  **Configuração do Firebase:**
    * Adicione o arquivo `google-services.json` na pasta `android/app/`.

4.  **Configuração do Google Maps:**
    * Abra o arquivo `android/app/src/main/AndroidManifest.xml`.
    * Procure pela tag `com.google.android.geo.API_KEY`.
    * Substitua o valor `SUA_CHAVE_AQUI` pela sua API Key válida do Google Cloud.
    ```xml
    <meta-data android:name="com.google.android.geo.API_KEY"
               android:value="COLE_SUA_CHAVE_AQUI"/>
    ```

5.  **Execute o App:**
    ```bash
    flutter run
    ```

---

## 📄 Estrutura de Pastas (MVC)

* `lib/models`: Classes de dados.
* `lib/views`: Telas e Widgets da interface.
* `lib/controllers`: Lógica de negócios (Auth, Restaurantes, Navegação).

---
Desenvolvido como Projeto Final da disciplina de Dispositivos Móveis.