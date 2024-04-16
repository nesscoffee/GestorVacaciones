<script>
    let username = '';
    let password = '';

    const LoginFunc = async () => {
        if (username.length == 0 || password.length == 0) {
            alert("Aún hay espacios requeridos en blanco.\n * = Campo requerido.")
        } else {
            await fetch('http://localhost:8080/api/iniciarSesion', {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({ username, password })
            })
            .then( res => { res.json().then( r => {
                switch (r) {
                    case 50001:
                        alert("El username introducido no existe en la base de datos.\nRevise que esté bien escrito.");
                        break;
                    case 50002:
                        alert("Contraseña incorrecta.\nSe bloqueará por 30 minutos si introduce más contraseñas incorrectas.");
                        break;
                    case 50003:
                        alert("Página bloqueada por seguridad.\nInténtelo de nuevo en 30 minutos.");
                        break;
                    case 0:
                        window.location.href = "http://localhost:8080/listaEmpleados";
                        break;
                }
            }) } )
        }
    }

</script>

<div class="login">
    <h1>Login</h1>
    <input type="text" placeholder="Nombre de usuario" required bind:value={username}>
    <label for="username" style="color: red;">*</label>
    <br>
    <input type="password" placeholder="Contraseña" required bind:value={password}>
    <label for="password" style="color: red;">*</label>
    <br>
    <button type="submit" on:click={LoginFunc}>
        LOGIN
    </button>
</div>

<style>
    :global(body) {
        background-color: #979797;
        font-family: 'Franklin Gothic Medium';
    }

    button {
        margin-top: 30px;
        margin-left: 50%;
        transform: translate(-50%, -50%);
        background-color: rgb(9, 175, 0);
        border: none;
        color: white;
        padding: 7px;
        border-radius: 4px;
    }

    button:hover {
        background-color: rgb(3, 59, 0);
        cursor: pointer;
    }

    .login {
        position: fixed;
        top: 50%;
        left: 50%;
        -webkit-transform: translate(-50%, -50%);
        transform: translate(-50%, -50%);
        padding: 20px;
        border-radius: 20px;
        width: max-content;
        background-color: #373737;
    }

    h1 {
        text-align: center;
        font-size: 30px;
        color: aliceblue;
        font-family: 'Franklin Gothic Medium';
    }

    input:invalid {
        border-color: red;
        border-width: 3px;
    }
</style>