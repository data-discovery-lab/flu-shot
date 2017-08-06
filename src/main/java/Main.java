import de.siegmar.fastcsv.writer.CsvAppender;
import de.siegmar.fastcsv.writer.CsvWriter;
import org.json.JSONObject;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.stream.Stream;

public class Main {

    private static File file;
    private static CsvWriter csvWriter = new CsvWriter();
    private static BufferedWriter writer;

    public static void main(String[] args) {

        String fileName = "flu-shot1.json";
        String outputFile = "flu-shot.converted.csv";



        try (Stream<String> stream = Files.lines(Paths.get(fileName))) {
//            file = new File(outputFile);
             writer = new BufferedWriter( new OutputStreamWriter(new FileOutputStream(outputFile), StandardCharsets.UTF_8));

            stream.forEach(l -> processLine(l));

            writer.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void processLine(String l) {

        JSONObject obj = new JSONObject(l);

        String text = obj.getString("text");

        String lang = obj.getString("lang");
        if (lang == null || !lang.toLowerCase().equals("en")) {
            return;
        }

        int favorourites_count = obj.getInt("favorite_count");

        try {

            JSONObject user = obj.getJSONObject("user");
            String userLocation = user.getString("location");

            writer.write(text);
            writer.write(",");
            writer.write(String.valueOf(favorourites_count));

            writer.newLine();

        } catch (IOException e) {
            e.printStackTrace();
        }

        System.out.println(text);
    }
}
