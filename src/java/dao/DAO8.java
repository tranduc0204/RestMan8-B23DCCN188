package dao;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.util.Properties;

public abstract class DAO8 {

    private static final String URL = "jdbc:mysql://localhost:3306/restman8"
            + "?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Ho_Chi_Minh";

    protected static Connection con;

    public DAO8() {
        if (con == null) {
            try {
                Properties config = new Properties();
                try (InputStream in = DAO8.class.getResourceAsStream("db.properties")) {
                    if (in != null) {
                        config.load(in);
                    }
                }
                String user = config.getProperty("user", "root");
                String password = config.getProperty("password", "your_password");

                Class.forName("com.mysql.cj.jdbc.Driver");
                con = DriverManager.getConnection(URL, user, password);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
