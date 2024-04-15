<script>
     import { page } from '$app/stores';

    let idEmpleado = $page.url.searchParams.get('empleado');
    let docId = '';
    let nombre = '';
    let idPuesto = '';

    let borrarEmpleado = () => {

    }
</script>

<div class="borrarEmpleado">
    <h1>Menú de borrar empleado</h1>
    <p>¿Está seguro que desea eliminar este empleado?</p>
    <p>Documento de identidad: {docId}</p>
    <p>Nombre: {nombre}</p>
    <button type="submit" on:click={borrarEmpleado}>Confirmar Borrado</button>
    <a href="/listaEmpleados">
        <button>Volver</button>
    </a>
</div>

<style>
    :global(body) {
        background-color: #979797;
        font-family: 'Franklin Gothic Medium';
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