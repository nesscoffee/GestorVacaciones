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
    const aplicarFiltro = async () => {
        
        await fetch('http://localhost:8080/api/getListaEmpleadosFiltro', {
            method: "POST",
            body: JSON.stringify({parametroBusqueda})
        })
        .then(res => { res.json().then(r => {
            empleados = r
        }) })

    }

    let selectorValue = 0;
    const setSelector = (event) => {
        selectorValue = event.currentTarget.value;
    }

    const logout = async () => {
        await fetch('http://localhost:8080/api/logout')
        .then(res => { res.json().then(r => {
            if (r == 0) {
                window.location.href = "http://localhost:8080/"
            }
        }) })
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
            <a href={`/consultarEmpleado?empleado=${selectorValue}`}>
                <button disabled={selectorValue==0 ? "a" : ""} >Consulta</button>
            </a>
            <a href={`/borrarEmpleado?empleado=${selectorValue}`}>
                <button disabled={selectorValue==0 ? "a" : ""}>Borrar</button>
            </a>
            <a href={`/actualizarEmpleado?empleado=${selectorValue}`}>
                <button disabled={selectorValue==0 ? "a" : ""}>Modificar</button>
            </a>
            <a href={`/listaMovimientos?empleado=${selectorValue}`}>
                <button disabled={selectorValue==0 ? "a" : ""}>Lista Movimientos</button>
            </a>
            <a href={`/insertarMovimiento?empleado=${selectorValue}`}>
                <button disabled={selectorValue==0 ? "a" : ""}>Insertar Movimiento</button>
            </a>
            <a href="/insertarEmpleado">
                <button>Insertar</button>
            </a>
            <button on:click={logout}>Logout</button>
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
                <td> <input type="radio" name="selector" id="selector" value={empleado.cedula} on:change={setSelector}> </td>
                <td>{empleado.cedula}</td>
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