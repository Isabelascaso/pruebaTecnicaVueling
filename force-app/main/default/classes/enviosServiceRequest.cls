public class enviosServiceRequest {
    public List<envioRequest> envios;

    public class envioRequest {
        public Date fecha_envio;
        public String id_producto;
        public String descripcion_producto;
        public Integer cantidad;
        public String almacen_destino;
    }
    
}