package br.uninovet;

// Icones SVG embutidos nas paginas (sem depender de arquivos ou CDN).
public class Icones {

    public static String svg(String nome) {
        String desenho;
        switch (nome) {
            case "inicio":
                desenho = "<path d='M3 11l9-8 9 8'/><path d='M5 10v10h14V10'/>";
                break;
            case "agenda":
                desenho = "<rect x='3' y='4' width='18' height='18' rx='2'/><path d='M16 2v4M8 2v4M3 10h18'/>";
                break;
            case "solicitacoes":
                desenho = "<path d='M22 12h-6l-2 3h-4l-2-3H2'/><path d='M5.45 5.11L2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z'/>";
                break;
            case "usuarios":
                desenho = "<path d='M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2'/><circle cx='9' cy='7' r='4'/><path d='M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75'/>";
                break;
            case "banco":
                desenho = "<ellipse cx='12' cy='5' rx='9' ry='3'/><path d='M21 12c0 1.66-4 3-9 3s-9-1.34-9-3'/><path d='M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5'/>";
                break;
            case "sair":
                desenho = "<path d='M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9'/>";
                break;
            case "arquivo":
                desenho = "<path d='M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z'/><path d='M14 2v6h6'/>";
                break;
            case "relogio":
                desenho = "<circle cx='12' cy='12' r='10'/><path d='M12 6v6l4 2'/>";
                break;
            case "celular":
                desenho = "<rect x='5' y='2' width='14' height='20' rx='2'/><path d='M12 18h.01'/>";
                break;
            default:
                desenho = "<circle cx='5.5' cy='10' r='2'/><circle cx='9.5' cy='5.5' r='2'/><circle cx='14.5' cy='5.5' r='2'/><circle cx='18.5' cy='10' r='2'/><path d='M12 11c-3 0-5 3-5 5.5 0 2 1.5 3 3 3 1 0 1.5-.5 2-.5s1 .5 2 .5c1.5 0 3-1 3-3C17 14 15 11 12 11z'/>";
        }
        return "<svg class='icone' viewBox='0 0 24 24' aria-hidden='true'>" + desenho + "</svg>";
    }

    public static String rotuloPerfil(String perfil) {
        if ("GERENTE".equals(perfil)) {
            return "Gerente";
        }
        if ("SECRETARIO".equals(perfil)) {
            return "Secretário";
        }
        if ("VETERINARIO".equals(perfil)) {
            return "Veterinário";
        }
        return Html.esc(perfil);
    }
}
