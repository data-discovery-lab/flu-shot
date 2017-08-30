import de.siegmar.fastcsv.writer.CsvAppender;
import de.siegmar.fastcsv.writer.CsvWriter;
import org.apache.commons.lang3.StringEscapeUtils;
import org.json.JSONObject;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.stream.Stream;

public class Main {

    private static File file;
    private static CsvWriter csvWriter = new CsvWriter();
    private static BufferedWriter writer;

    private static List<String> fileList;

    public static void main(String[] args) throws Exception{

        String fileName = "flu-shot.json";

        if (args.length > 0 && args[0].length() > 0) {
            fileName = args[0];
        }


        try (Stream<Path> paths = Files.walk(Paths.get("data/TEST"))) {
            paths
                    .filter(Files::isRegularFile)
                    .forEach(f -> convertFile(f.toString()));
        }

//        convertFile(fileName);

    }

    private static String getOutputFilename(String inputFile) {
        String outputFolder = "data/converted";
        String fName = inputFile.substring(inputFile.lastIndexOf("/") + 1, inputFile.lastIndexOf(".")) + ".converted.csv";

        return outputFolder + "/" + fName;
    }

    private static void convertFile(String fileName) {
        String outputFile = getOutputFilename(fileName);

        try (Stream<String> stream = Files.lines(Paths.get(fileName))) {
//            file = new File(outputFile);
            writer = new BufferedWriter( new OutputStreamWriter(new FileOutputStream(outputFile), StandardCharsets.UTF_8));

            // write header
            writer.write("user Id"); // user id
            writer.write(",");

            writer.write("tweet"); // tweet
            writer.write(",");

            writer.write("created_at"); // created at
            writer.write(",");
            writer.write("state"); // state

            writer.newLine();

            stream.forEachOrdered(l -> processLine(l));

            writer.flush();
            writer.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void processLine(String l) {

        JSONObject obj = new JSONObject(l);

        String text = obj.getString("text");

        if (text == null || text.isEmpty() ) {
            return;
        }

        if (!text.toLowerCase().contains("shot")) {
            return;
        }


        try {

            JSONObject user = obj.getJSONObject("user");

            writer.write(user.getString("id_str")); // user id
            writer.write(",");
            writer.write(StringEscapeUtils.escapeCsv(text)); // tweet
            writer.write(",");
            writer.write(obj.getString("created_at")); // created at

            JSONObject tweetLoc = obj.getJSONObject("geocoded");
            if (tweetLoc != null) {
                writer.write(",");
                writer.write(tweetLoc.optString("state")); // state
            }


            writer.newLine();

        } catch (IOException e) {
            e.printStackTrace();
        }
        catch (Exception ex) {
            ex.printStackTrace();
        }

        System.out.println(text);
    }
}
