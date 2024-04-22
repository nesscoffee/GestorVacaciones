<script>
    import { page } from '$app/stores';

    let cedula = $page.url.searchParams.get('empleado');
    let oldDocId = '';
    let docId = '';
    let nombre = '';
    let idPuesto = '';

    let loadData = async () => {
        await fetch("http://localhost:8080/api/getInfoEmpleado", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify( {cedula} )
        })
        .then( res => { res.json().then(r => {
            oldDocId = docId = r[0].cedula;
            nombre = r[0].nombre;
            idPuesto = r[0].puesto;
        }) } )
    }

    $: loadData();

    let actualizarEmpleado = async () => {
        await fetch("http://localhost:8080/api/actualizarEmpleado", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify( {oldDocId, docId, nombre, idPuesto} )
        })
        .then( res => { res.json().then(r => {
            switch (r) {
                case 50009:
                    alert('El nombre contiene caracteres que no están en el alfabeto.')
                    break;
                case 50010:
                    alert('La cédula contiene caracteres que no son números.')
                    break;
                case 50007:
                    alert('Ya existe un empleado con ese nombre.')
                    break;
                case 50006:
                    alert('Ya existe un empleado con esa cedula.')
                    break;
                case 50008:
                    alert('Ocurrio un error interno en la base de datos.')
                    break;
                case 0:
                    alert('Empleado actualizado con exito')
                    window.location.href = "http://localhost:8080/listaEmpleado"
                    break;
            }
        }) } )
    }
</script>

<div class="insertarEmpleado">
    <h1>Menú de actualizar empleado</h1>
    <div class="inputs">
        <label for="docId">Valor del documento de identidad (cédula):</label>
        <input type="text" bind:value={docId} id="docId" required placeholder="X-XXXX-XXXX">
        <label for="docId" style="color: red;">*</label>
            <br>
        <label for="nombre">Nombre:</label>
        <input type="text" id="nombre" required bind:value={nombre}>
        <label for="nombre" style="color: red;">*</label>
            <br>
        <label for="idPuesto">Escoja un puesto:</label>
        <select name="idPuesto" id="idPuesto" bind:value={idPuesto}>
            <option value="Cajero">Cajero</option>
            <option value="Camarero">Camarero</option>
            <option value="Cuidador">Cuidador</option>
            <option value="Conductor">Conductor</option>
            <option value="Asistente">Asistente</option>
            <option value="Recepcionista">Recepcionista</option>
            <option value="Fontanero">Fontanero</option>
            <option value="Niñera">Niñera</option>
            <option value="Conserje">Conserje</option>
            <option value="Albañil">Albañil</option>
        </select>
        <label for="idPuesto" style="color: red;">*</label>
            <br>
        <button type="submit" on:click={actualizarEmpleado}>Actualizar Empleado</button>
        <a href="/listaEmpleados">
            <button>Volver</button>
        </a>
    </div>
</div>

<style>
    :global(body) {
        background-color: #979797;
        font-family: 'Franklin Gothic Medium';
    }

    input:invalid {
        border-color: red;
        border-width: 3px;
    }

    button {
        margin-top: 20px;
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