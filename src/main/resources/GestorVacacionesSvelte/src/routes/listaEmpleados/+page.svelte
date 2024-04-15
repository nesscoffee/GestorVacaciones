<script>
    let loadData = () => {
        // Fetch data
    }

    $: loadData();

    let horaActual = "";
    const updateTime = () => {
        horaActual = new Date().toLocaleTimeString('es-CR');
    }
    setInterval(updateTime, 1000);

    let parametroBusqueda = "";
    const aplicarFiltro = () => {
        let parametro = parseInt(parametroBusqueda);

        if ( isNaN(parametro) ) {
            // Si son letras
        } else {
            // Si son numeros
        }
    }
</script>

<div class="lista">
    <div class="navbar">
        <div class="navbar-text">
            <p>GESTOR VACACIONES</p>
        </div>
        <div class="navbar-clock">
            {horaActual}
        </div>
        <div class="navbar-buttons">
            <button disabled id="selectedButton">Consulta</button>
            <button disabled id="selectedButton">Borrar</button>
            <button disabled id="selectedButton">Modificar</button>
            <a href="/insertarEmpleado">
                <button>Insertar</button>
            </a>
            <a href="/">
                <button>Logout</button>
            </a>
        </div>
    </div>

    <div>
        <label for="inputBusqueda">Filtrar: </label>
        <input type="text" placeholder="Parámetro" id="inputBusqueda" bind:value={parametroBusqueda}>
        <button type="submit" on:click={aplicarFiltro}>Filtrar</button>
    </div>

    <div class="lista" id="lista"></div>


</div>

<style>
    :global(body) {
        background-color: #979797;
        font-family: 'Franklin Gothic Medium';
    }
    
    .navbar {
        display: flex;
        background-color: #373737;
    }

    .navbar-text {
        flex: 1;
        color: white;
        padding: 5px;
        padding-left: 20px;
    }

    .navbar-buttons {
        flex: right;
        padding: 20px;
    }

    .navbar-clock {
        width: 30%;
        color: white;
        padding: 20px;
    }

    button {
        background-color: #979797;
        border: none;
        padding: 5px;
        border-radius: 5px;
    }

    button:hover {
        background-color: #585858;
        cursor: pointer;
    }

</style>