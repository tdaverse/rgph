

/*
 *	Copyright (C) 2017 Visualization & Graphics Lab (VGL), USF
 *
 *	This file is part of libRGSimp, a library to compute persistence of Reeb graphs.
 *
 *	libRGSimp is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU Lesser General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	libRGSimp is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU Lesser General Public License for more details.
 *
 *	You should have received a copy of the GNU Lesser General Public License
 *	along with libRG.  If not, see <http://www.gnu.org/licenses/>.
 *
 *	Author(s):	Junyi Tu
 *	Version	 :	1.0
 *
 *	Modified by : --
 *	Date : --
 *	Changes  : --
 */
package usf.saav.cmd;

import usf.saav.common.TimerNanosecond;
import usf.saav.topology.reebgraph.ReebGraph;
import usf.saav.topology.reebgraph.pairing.MergePairing;

import java.util.*;

import java.util.ArrayList;


public class MergePairingCLI {
    //change rg to null to test
    static ArrayList<ReebGraph> rg = null;
    static List<String> pTypes = new ArrayList<>();
    static List<String> vTypes = new ArrayList<>();
    static List<Float> pValues = new ArrayList<>();
    static  List<Float> vValues = new ArrayList<>();
    static  List<Float> pRealValues = new ArrayList<>();
    static List<Float> vRealValues = new ArrayList<>();
    static List<Integer> pGlobalIDs = new ArrayList<>();
    static List<Integer> vGlobalIDs = new ArrayList<>();
    static String[] finalGraph = null;
    static double elapsedTime = 0;

    public static String[] getFinalGraph() {
        return finalGraph;
    }

    public static void main(String[] args) {

        if (args.length == 0) {
            System.out.println("");
            System.out.println("   ###################################################################################");
            System.out.println("   Propagate and pair: A single-pass approach to critical point pairing in reeb graphs");
            System.out.println("   International Symposium on Visual Computing, Springer, Cham, 2019");
            System.out.println("   Junyi Tu, Mustafa Hajij, and Paul Rosen");
            System.out.println("");
            System.out.println("   Usage:");
            System.out.println("      > java -jar ReebGraphPairingMP.jar <file1> <file2> ... <fileN>");
            System.out.println("");
        } else {
            for (String ip : args) {
                try {
                    System.out.println(ip);
                    rg = TestResults.runAlgo(ip, new MergePairing(), new TimerNanosecond(), false);
                    finalGraph = TestResults.getPersistentDiagramCSV(rg);
                    ResultList resultList = TestResults.getResultList(rg);
                    pTypes = resultList.pTypes;
                    vTypes = resultList.vTypes;
                    pValues = resultList.pValues;
                    vValues = resultList.vValues;
                    pRealValues = resultList.pRealValues;
                    vRealValues = resultList.vRealValues;
                    pGlobalIDs = resultList.pGlobalIDs;
                    vGlobalIDs = resultList.vGlobalIDs;
                    System.out.println();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }

    // This method is called from R via rJava.  Its signature declares
    // throws Exception so that any failure (bad input, algorithm error,
    // etc.) propagates as an rJava / R error rather than being silently
    // swallowed.  The R side does not need to check for stale results.
    public static void mainR(int[] vertexIds,
                                    float[] vertexWeights,
                                    int[] edgeOriginIds,
                                    int[] edgeDestinationIds) throws Exception {
        // Clear static result fields before attempting computation.
        // If an exception occurs below, stale data from a prior call
        // must not leak into the results retrieved by the R side.
        rg = null;
        pTypes = new ArrayList<>();
        vTypes = new ArrayList<>();
        pValues = new ArrayList<>();
        vValues = new ArrayList<>();
        pRealValues = new ArrayList<>();
        vRealValues = new ArrayList<>();
        pGlobalIDs = new ArrayList<>();
        vGlobalIDs = new ArrayList<>();
        finalGraph = null;
        elapsedTime = 0;

        PairingResult result = TestResults.runAlgo(vertexIds,
                vertexWeights,
                edgeOriginIds,
                edgeDestinationIds,
                new MergePairing(),
                new TimerNanosecond(),
                false);
        rg = result.getReebGraphArrayList();
        elapsedTime = result.getElapsedTime();

        ResultList resultList = TestResults.getResultList(rg);
        pTypes = resultList.pTypes;
        vTypes = resultList.vTypes;
        pValues = resultList.pValues;
        vValues = resultList.vValues;
        pRealValues = resultList.pRealValues;
        vRealValues = resultList.vRealValues;
        pGlobalIDs = resultList.pGlobalIDs;
        vGlobalIDs = resultList.vGlobalIDs;
    }

    private static float[] convertFloatListToArray(List<Float> list) {
        float[] arr = new float[list.size()];
        for(int i = 0; i < list.size(); i++) {
            arr[i] = list.get(i);
        }
        return arr;
    }

    private static int[] convertIntegerListToArray(List<Integer> list) {
        int[] arr = new int[list.size()];
        for(int i = 0; i < list.size(); i++) {
            arr[i] = list.get(i);
        }
        return arr;
    }

    private static String[] convertStringListToArray(List<String> list) {
        String[] arr = new String[list.size()];
        for(int i = 0; i < list.size(); i++) {
            arr[i] = list.get(i);
        }
        return arr;
    }

    public static String[] getPTypes() {
        return convertStringListToArray(pTypes);
    }
    public static String[] getVTypes() {
        return convertStringListToArray(vTypes);
    }

    public static float[] getPRealValues() {
        return convertFloatListToArray(pRealValues);
    }

    public static float[] getVRealValues() {
        return convertFloatListToArray(vRealValues);
    }
    public static float[] getPValues() {
        return convertFloatListToArray(pValues);
    }
    public static float[] getVValues() {
        return convertFloatListToArray(vValues);
    }
    public static int[] getPGlobalIDs() {return convertIntegerListToArray(pGlobalIDs);}
    public static int[] getVGlobalIDs() {return convertIntegerListToArray(vGlobalIDs);}
    public static double getElapsedTime() {return elapsedTime;}
}


