

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

    public static void mainR(int[] vertexIds,
                                    float[] vertexWeights,
                                    int[] edgeOriginIds,
                                    int[] edgeDestinationIds) {
        try {
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
            pValues = resultList.pValues;
            vValues = resultList.vValues;
            pRealValues = resultList.pRealValues;
            vRealValues = resultList.vRealValues;
            pGlobalIDs = resultList.pGlobalIDs;
            vGlobalIDs = resultList.vGlobalIDs;
        } catch (Exception e) {
            e.printStackTrace();
        }
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


