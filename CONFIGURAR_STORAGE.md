# Como Configurar o Firebase Storage

O erro 404 geralmente indica que o Firebase Storage não está habilitado ou as regras não estão configuradas.

## Passo 1: Habilitar o Firebase Storage

1. Acesse o [Firebase Console](https://console.firebase.google.com)
2. Selecione o projeto: **mentora-fd18a**
3. No menu lateral, clique em **Storage**
4. Se aparecer um botão **"Começar"** ou **"Get Started"**, clique nele
5. Escolha o modo de produção (Production mode)
6. Selecione a localização do bucket (escolha a mais próxima do Brasil, como `southamerica-east1`)
7. Clique em **"Concluído"** ou **"Done"**

## Passo 2: Configurar as Regras de Segurança

1. Ainda na página do Storage, clique na aba **"Rules"** (Regras)
2. Cole o seguinte código:

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    // Regras para fotos de perfil
    match /profile_pictures/{userId}.jpg {
      // Permitir leitura para todos os usuários autenticados
      allow read: if request.auth != null;
      
      // Permitir escrita apenas para o próprio usuário
      allow write: if request.auth != null 
        && request.auth.uid == userId
        && request.resource.size < 5 * 1024 * 1024 // Máximo 5MB
        && request.resource.contentType.matches('image/.*');
      
      // Permitir delete apenas para o próprio usuário
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
    
    // Negar acesso a todos os outros arquivos
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

3. Clique em **"Publicar"** ou **"Publish"**

## Passo 3: Verificar se está funcionando

1. Tente fazer upload de uma foto novamente no app
2. Se ainda der erro, verifique:
   - Se o Storage está realmente habilitado (deve aparecer um bucket na página)
   - Se as regras foram publicadas (deve aparecer "Published" ao lado das regras)
   - Se você está logado no app

## Regras Temporárias para Teste (Menos Seguras)

Se precisar testar rapidamente, use estas regras temporárias:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**⚠️ IMPORTANTE:** Estas regras permitem que qualquer usuário autenticado faça upload de qualquer arquivo. Use apenas para testes e depois substitua pelas regras seguras acima.

## Solução de Problemas

### Erro 404 (Object does not exist)
- **Causa:** Storage não está habilitado
- **Solução:** Siga o Passo 1 acima

### Erro 403 (Permission denied)
- **Causa:** Regras de segurança não permitem o upload
- **Solução:** Siga o Passo 2 acima e verifique se as regras foram publicadas

### Erro de conexão
- **Causa:** Problema de internet ou timeout
- **Solução:** Verifique sua conexão e tente novamente

