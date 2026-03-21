package BAITHUCHANH.TUAN8;

import java.io.BufferedReader;
import java.io.FileReader;
import java.util.ArrayList;

public class test {
    public static void main(String[] args) {

        // FileWriter Fw;
        // BufferedWriter Bw = null;
        // try {
        //     Fw = new FileWriter("ABC.txt");
        //     Bw = new BufferedWriter(Fw);
        // } catch (Exception e) {
        //     System.out.println("Sai roiof thk ngu");
        // }
        // String chuoi = "";

        // // @SuppressWarnings("unused")
        // ArrayList<taikhoanBank> AAA = new ArrayList<>();
        // taikhoanBank tk = new taikhoanBank("4564", "khanh", 500000, "123456");
        // taikhoanBank tk2 = new taikhoanBank("123", "Nam22", 500000, "123456");
        // AAA.add(tk);
        // AAA.add(tk2);
        // for(int i = 0; i < AAA.size(); i++)
        // {
        //     chuoi += AAA.get(i).toString() + "\n";
        // }
        // try {
        //     Bw.write(chuoi);
        //     Bw.close();
        // } catch (Exception e) {
        //     // TODO: handle exception
        // }

        FileReader Fr;
        BufferedReader Br = null;
        ArrayList<taikhoanBank> AAA = new ArrayList<>();
        String line = "";
        try {
            Fr = new FileReader("ABC.txt");
            Br = new BufferedReader(Fr);
            while ((line = Br.readLine()) != null) {
                String[] parts = line.split(",");
                taikhoanBank tk = new taikhoanBank(parts[0], parts[1], Double.parseDouble(parts[2]), parts[3]);
                AAA.add(tk);
            }
        } catch (Exception e) {
            // TODO: handle exception
        }

        for(int i = 0; i < AAA.size(); i++)
        {
            System.out.println(AAA.get(i).toString());
        }
    }
}
