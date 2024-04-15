<script>
    let docId = '';
    let nombre = '';
    let idPuesto = '';

    let insertarEmpleado = () => {

    }
</script>

<div class="insertarEmpleado">
    <h1>Menú de insertar empleado</h1>
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
        <select name="idPuesto" id="idPuesto">
            <!-- Elementos -->
        </select>
        <label for="idPuesto" style="color: red;">*</label>
            <br>
        <button type="submit" on:click={insertarEmpleado}>Insertar Empleado</button>
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