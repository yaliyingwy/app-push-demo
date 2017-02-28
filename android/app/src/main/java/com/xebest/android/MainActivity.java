package com.xebest.android;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import org.json.JSONException;
import org.json.JSONObject;

import java.net.URISyntaxException;

import io.socket.client.IO;
import io.socket.client.Socket;
import io.socket.emitter.Emitter;


public class MainActivity extends AppCompatActivity {

    private Button btn;
    private EditText textView;
    private Socket socket;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        btn = (Button) findViewById(R.id.button);
        textView = (EditText) findViewById(R.id.text);

        btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (textView.getText().length() == 0) {
                    Toast toast = Toast.makeText(getApplicationContext(),
                            "请输入内容", Toast.LENGTH_LONG);
                    toast.setGravity(Gravity.CENTER, 0, 0);
                    toast.show();
                } else if (socket != null) {
                    JSONObject obj = new JSONObject();
                    try {
                        obj.put("msg", textView.getText());
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    socket.emit("msg", obj);
                }
            }
        });


        try {
            IO.Options opts = new IO.Options();
            opts.forceNew = true;
            opts.reconnection = false;
            socket = IO.socket("http://localhost:3000", opts);
            socket.on(Socket.EVENT_CONNECT_ERROR, new Emitter.Listener() {
                @Override
                public void call(Object... args) {
                    Log.e("err:", args[0].toString());
                }
            }).on("news", new Emitter.Listener() {

                @Override
                public void call(final Object... args) {

                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Toast toast = Toast.makeText(getApplicationContext(),
                                    args[0].toString(), Toast.LENGTH_LONG);
                            toast.setGravity(Gravity.CENTER, 0, 0);
                            toast.show();
                        }
                    });
                    Log.d("news:", args[0].toString());

                }

            });
            socket.connect();
        } catch (URISyntaxException e) {
            e.printStackTrace();
        }

    }
}
