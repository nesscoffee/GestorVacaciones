package Database;

import java.util.ArrayList;

public class Result {
    
    private ArrayList<Integer> resultCodes;
    private ArrayList<Object> dataset;

    public Result (){
        resultCodes = new ArrayList<>();
        dataset = new ArrayList<>();
    }

    public void addCode (int resultCode){
        resultCodes.add(resultCode);
    }

    public void addDatasetItem (Object item){
        dataset.add(item);
    }

    public ArrayList<Integer> getResultCodes (){
        return this.resultCodes;
    }

    public ArrayList<Object> getDataset (){
        return this.dataset;
    }
}
