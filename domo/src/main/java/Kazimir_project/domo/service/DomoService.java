package Kazimir_project.domo.service;

import Kazimir_project.domo.dto.SearchDto;
import org.apache.http.HttpEntity;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class DomoService {

    List<Map<String, List<String>>> allInvaders = new ArrayList<>();
    String n = "\n\"\\n,:";

    public String getInvaderJava() throws IOException {
        String url = "http://radar.lafox.net/api/getInvaders";
        return getData(url);
    }

    public String getMapJava() throws IOException {
        String url = "http://radar.lafox.net/api/getMap";
        return getData(url);
    }

    public String getData(String url) throws IOException {
        CloseableHttpClient httpclient = HttpClients.createDefault();
        try {
            HttpGet httpget = new HttpGet(url);
            ResponseHandler<String> responseHandler = response -> {
                int status = response.getStatusLine().getStatusCode();
                if (status >= 200 && status < 300) {
                    HttpEntity entity = response.getEntity();
                    return entity != null ? EntityUtils.toString(entity) : null;
                } else {
                    throw new ClientProtocolException("Unexpected response status: " + status);
                }
            };
            String responseBody = httpclient.execute(httpget, responseHandler);
            return responseBody;
        } finally {
            httpclient.close();
        }
    }

    public int countInvaderPoints(List<String> invader) {

        int invaderPointQuantity = 0;

        for (int i = 0; i < invader.size(); i++) {
            for (int k = 0; k < invader.get(i).length(); k++) {
                invaderPointQuantity += 1;
            }
        }
        return invaderPointQuantity;
    }



    public List<Map<String, String>> findInvaders(SearchDto searchDto) {

        List<Map<String, String>> result = new ArrayList<>();

        //Получение значения карты и захватчиков
        String map = searchDto.getMap();
        List<Map<String, String>> invaders = searchDto.getInvaders();

        //Значение для записи в result
        Map<String, String> invaderMapValue = new HashMap<>();

        //Листы для алгоритма поиска захватчиков на карте
        List<String> finalMap = new ArrayList<>();
        List<String> individualInvaderList = new ArrayList<>();

        //Добваление значений ключа
        String[] invaderName = new String[2];
        invaderName[0] = "INVADER_1";
        invaderName[1] = "INVADER_2";
        invaderName[2] = "INVADER_3";
        //Переменная хранения значения ключа
        String name;

        //Переменные для алгоритма поиска
        int acceptablePointsCount;
        int invaderPointQuantity;
        int commonPoints;
        int subRow;
        int subElement;
        int invRow;
        int invElement;
        int numOfSubRows;

        //Создание мап листа карты
        for (String prettyMap : map.split("\n")) {
            finalMap.add(prettyMap);
        }

        //Получает имя (ключ) захватчика и присваивает individualInvader его значение; подсчитывает кол-во точек захватчика
        for (int k = 0; k < invaderName.length; k++) {

            name = invaderName[k];
            String individualInvader = invaders.get(k).get(name);

            acceptablePointsCount = Integer.parseInt(invaders.get(k).get("acceptablePointsCount"));

            //Формирует эррэй лист для каждого из захватчиков, разделенным по слэш n
            for (String invOneSting : individualInvader.split("\n")) {
                individualInvaderList.add(invOneSting);
            }

            //Количество точек захватчика
            invaderPointQuantity = countInvaderPoints(individualInvaderList);

            //Ищет всех захватчиков одного вида на карте
            for (int mapRow = 0; mapRow < finalMap.size(); mapRow++) {

                for (int mapElement = 0; mapElement < finalMap.get(mapRow).length(); mapElement++) {

                    invRow = 0;
                    commonPoints = 0;
                    numOfSubRows = 0;

                    for (subRow = mapRow; subRow < finalMap.size(); subRow++) {
                        invElement = 0;
                        if (numOfSubRows == individualInvaderList.size()) break;
                        for (subElement = mapElement; subElement < finalMap.get(0).length(); subElement++) {
                            if (individualInvaderList.get(invRow).charAt(invElement) == finalMap.get(subRow).charAt(subElement)) {
                                commonPoints++;
                            }
                            invElement++;
                            if (invElement == individualInvaderList.get(0).length()) break;
                        }
                        invRow++;
                        numOfSubRows++;
                    }
                    if (commonPoints - acceptablePointsCount < commonPoints & commonPoints <= invaderPointQuantity)
                        invaderMapValue.put("name", name);
                        invaderMapValue.put("x", String.valueOf(mapElement));
                        invaderMapValue.put("y", String.valueOf(mapRow));
                        result.add(invaderMapValue);
                        invaderMapValue.clear();
                }
            }
        }
        return result;
    }

}





















//    public PrettyInvaders createInvaders(InvaderDto invaders) {
//
//        InvaderEntity entity = new InvaderEntity();
//        entity.setINVADER_1(invaders.getINVADER_1());
//        entity.setINVADER_2(invaders.getINVADER_2());
//        entity.setINVADER_3(invaders.getINVADER_3());
//
//        String first = entity.getINVADER_1();
//        String second = entity.getINVADER_2();
//        String third = entity.getINVADER_3();
//
//        PrettyInvaders prettyInvaders = new PrettyInvaders();
//        prettyInvaders.addAllInvaders(first, second, third);
//        return prettyInvaders;
//    }
//
//    public PrettyMap createMap(MapDto mapDto) {
//
//        MapEntity entity = new MapEntity();
//        entity.setMap(mapDto.getMap());
//
//        String mapString = entity.getMap();
//
//        PrettyMap prettyMap = new PrettyMap();
//        prettyMap.addMap(mapString);
//        return prettyMap;
//    }