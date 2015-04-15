namespace Network.Widgets {

	public class ConfigurationPage : Gtk.Box {
		private const string DEFAULT_PROXY = "host:port";
        private bool syntax_error = false;

		public ConfigurationPage () {
			this.margin_start = 20;
			this.margin_top = this.margin_start;
			this.orientation = Gtk.Orientation.VERTICAL;
			this.spacing = 10;
			this.margin_end = 55;

			var direct_btn = new Gtk.RadioButton.with_label_from_widget (null, "Direct internet connection");
			var auto_btn = new Gtk.RadioButton.with_label_from_widget (direct_btn, "Automatic proxy configuration");
			var manual_btn = new Gtk.RadioButton.with_label_from_widget (auto_btn, "Manual proxy configuration");

			var auto_entry = new Gtk.Entry ();
			auto_entry.placeholder_text = _("URL to configuration script");
			auto_entry.hexpand = true;
			auto_entry.sensitive = false;

			var auto_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 15);
			auto_box.add (auto_btn);
			auto_box.add (auto_entry);

            var setup_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 40);
            setup_box.vexpand = false;
            setup_box.margin_top = 15;
            setup_box.margin_start = 20;

            var vbox_label = new Gtk.Box (Gtk.Orientation.VERTICAL, 25);
            vbox_label.margin_top = 5;

            var vbox_entry = new Gtk.Grid ();
            vbox_entry.row_spacing = 15;
            vbox_entry.column_spacing = 20;
            vbox_entry.column_homogeneous = false;
            vbox_entry.hexpand = false;

            var http_l = new Gtk.Label (_("HTTP Proxy:"));
            http_l.halign = Gtk.Align.START;

            var https_l = new Gtk.Label (_("HTTPS Proxy:")); 
            https_l.halign = Gtk.Align.START;

            var ftp_l = new Gtk.Label (_("FTP Proxy:"));
            ftp_l.halign = Gtk.Align.START;

            var socks_l = new Gtk.Label (_("SOCKS Host:"));            
            socks_l.halign = Gtk.Align.START;

            var http = new Gtk.Entry ();
            http.placeholder_text = DEFAULT_PROXY;

            var https = new Gtk.Entry ();
            https.placeholder_text = DEFAULT_PROXY;
            https.input_purpose = Gtk.InputPurpose.NUMBER;

            var ftp = new Gtk.Entry ();
            ftp.placeholder_text = DEFAULT_PROXY;

            var socks = new Gtk.Entry ();
            socks.placeholder_text = DEFAULT_PROXY;

            var apply_btn = new Gtk.Button.with_label (_("Apply"));
            apply_btn.get_style_context ().add_class ("suggested-action");
            
            var reset_btn = new Gtk.Button.with_label ("Reset all settings");
            reset_btn.clicked.connect (on_reset_btn_clicked);

            vbox_label.add (http_l);
            vbox_label.add (https_l);
            vbox_label.add (ftp_l);
            vbox_label.add (socks_l);

            vbox_entry.attach (http, 0, 0, 1, 1);
            vbox_entry.attach (https, 0, 1, 1, 1);
            vbox_entry.attach (ftp, 0, 2, 1, 1);
            vbox_entry.attach (socks, 0, 3, 1, 1);

            setup_box.add (vbox_label);
            setup_box.add (vbox_entry);

			auto_btn.toggled.connect (() => {
				if (auto_btn.get_active ())
					auto_entry.sensitive = true;
				else
					auto_entry.sensitive = false;		
			});


			manual_btn.toggled.connect (() => {
				if (manual_btn.get_active ())
					setup_box.sensitive = true;
				else
					setup_box.sensitive = false;		
			});

			apply_btn.clicked.connect (() => {
				if (auto_btn.get_active ()) {
					if (auto_entry.get_text () != "") {
						proxy_settings.autoconfig_url = auto_entry.get_text ();
						proxy_settings.mode = "auto";
					}	

				} else if (manual_btn.get_active ()) {
					if (http.get_text () != "") {
                        if (http.get_text ().contains (":")) {
						    http_settings.host = http.get_text ().split (":")[0];
						    http_settings.port = int.parse (http.get_text ().split (":")[1]);	
                            set_syntax_error_for_entry (http, false);
                        } else {
                            set_syntax_error_for_entry (http, true);
                        }
					}

					if (https.get_text () != "") {
                        if (https.get_text ().contains (":")) {
						    https_settings.host = https.get_text ().split (":")[0];
						    https_settings.port = int.parse (https.get_text ().split (":")[1]);	
                            set_syntax_error_for_entry (https, false);
                        } else {
                            set_syntax_error_for_entry (https, true);
                        }
					}

					if (ftp.get_text () != "") {
                        if (ftp.get_text ().contains (":")) {
						    ftp_settings.host = ftp.get_text ().split (":")[0];
						    ftp_settings.port = int.parse (ftp.get_text ().split (":")[1]);	
                            set_syntax_error_for_entry (ftp, false);
                        } else {
                            set_syntax_error_for_entry (ftp, true);
                        }
					}

					if (socks.get_text () != "") {
                        if (socks.get_text ().contains (":")) {
						    socks_settings.host = socks.get_text ().split (":")[0];
						    socks_settings.port = int.parse (socks.get_text ().split (":")[1]);	
                            set_syntax_error_for_entry (socks, false);
                        } else {
                            set_syntax_error_for_entry (socks, true);
                        }
					}

					if ((http.get_text () + https.get_text () + ftp.get_text () + socks.get_text () != "") && !syntax_error)
						proxy_settings.mode = "manual";

				} else if (direct_btn.get_active ()) {
					proxy_settings.mode = "none";
				}
			});

			switch (proxy_settings.mode) {
				case "none":
					direct_btn.active = true;
					setup_box.sensitive = false;
					break;
				case "manual":
					manual_btn.active = true;
					setup_box.sensitive = true;
					break;
				case "auto":
					auto_btn.active = true;
					setup_box.sensitive = false;
					break;		
			}	

			var apply_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
			apply_box.layout_style = Gtk.ButtonBoxStyle.EXPAND;
			apply_box.add (reset_btn);
			apply_box.add (apply_btn);   

            vbox_entry.attach (apply_box, 0, 4, 1, 1);

			this.add (direct_btn);
			this.add (auto_box);
			this.add (manual_btn);
			this.add (setup_box);
			//this.add (apply_box);
		}

        private void set_syntax_error_for_entry (Gtk.Entry entry, bool error) {
            if (error) {
                entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "dialog-error");
                syntax_error = true;
            } else {
                entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "");
                syntax_error = false;
            }
        }
        
        private void on_reset_btn_clicked () {
            var reset_dialog = new Gtk.MessageDialog (null, Gtk.DialogFlags.MODAL, Gtk.MessageType.INFO, Gtk.ButtonsType.NONE, " ");

            reset_dialog.text = _("Do you want to reset all the settings to
default values inluding hosts and ports?");
            reset_dialog.add_button (_("Do not reset"), 0);
            reset_dialog.add_button (_("Reset"), 1);

            reset_dialog.deletable = false;
            reset_dialog.show_all ();
            reset_dialog.response.connect ((response_id) => {
                switch (response_id) {
                    case 0:
                        break;
                    case 1:
                        proxy_settings.mode = "none";
                        proxy_settings.autoconfig_url = "";
                        http_settings.host = "";
                        http_settings.port = 0;
                        https_settings.host = "";
                        https_settings.port = 0;
                        ftp_settings.host = "";
                        ftp_settings.port = 0;   
                        socks_settings.host = "";
                        socks_settings.port = 0;                                                                        
                        break;
                    } 

                reset_dialog.destroy ();                    
            });         
        }
	}
}	
