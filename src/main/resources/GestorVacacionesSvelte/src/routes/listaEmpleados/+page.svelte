<script>
    let empleados = [];

    let loadData = async () => {
        await fetch("http://localhost:8080/api/getListaEmpleados")
        .then(response => response.json())
        .then(resData => {
            empleados = resData;
        })
        .catch(e => {console.log(e)});
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

    <div class="lista" id="lista">
        <table>
            <tr>
                <th>Selector</th>
                <th>Documento Identidad</th>
                <th>Nombre</th>
            </tr>
            {#each empleados as empleado}
            <tr>
                <td> <input type="radio" name="selector" id="selector" value={empleado.valorDocumentoIdentidad}> </td>
                <td>{empleado.valorDocumentoIdentidad}</td>
                <td>{empleado.nombre}</td>
            </tr>
            {/each}
        </table>
    </div>


</div>

<style>
    :global(body) {
        background-color: #979797;
        font-family: 'Franklin Gothic Medium';
    }

    table, th, td {
        margin-top: 15px;
        border: 1px solid black;
        border-collapse: collapse;
        padding: 10px;
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
        background-color: #d0d0d0;
        border: none;
        padding: 5px;
        border-radius: 5px;
    }

    button:hover {
        background-color: #585858;
        cursor: pointer;
    }

</style>