package usf.saav.cmd;

import usf.saav.topology.reebgraph.ReebGraph;

import java.util.ArrayList;

public class PairingResult {

    private ArrayList<ReebGraph> reebGraphArrayList;
    private double elapsedTime;

    public PairingResult(ArrayList<ReebGraph> reebGraphArrayList, double elapsedTime) {
        this.reebGraphArrayList = reebGraphArrayList;
        this.elapsedTime = elapsedTime;
    }

    public ArrayList<ReebGraph> getReebGraphArrayList() {
        return reebGraphArrayList;
    }

    public void setReebGraphArrayList(ArrayList<ReebGraph> reebGraphArrayList) {
        this.reebGraphArrayList = reebGraphArrayList;
    }

    public double getElapsedTime() {
        return elapsedTime;
    }

    public void setElapsedTime(double elapsedTime) {
        this.elapsedTime = elapsedTime;
    }
}
