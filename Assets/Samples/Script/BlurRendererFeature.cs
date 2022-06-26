using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class BlurRendererFeature : ScriptableRendererFeature
{
    [SerializeField] Shader m_shader;
    [SerializeField] string m_textureId;
    [SerializeField] float m_factor;
    [SerializeField] private RenderPassEvent m_renderPassEvent = RenderPassEvent.AfterRenderingSkybox;

    private BlurRendererPass m_pass;
    private float m_savedFactor;

    public override void Create()
    {
        // インスペクタからm_factorを変更したら反映されるように
        if (!Mathf.Approximately(m_savedFactor, m_factor) || m_pass == null)
        {
            m_pass = new BlurRendererPass(m_shader, m_textureId, m_factor, m_renderPassEvent);
            m_savedFactor = m_factor;
        }
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        m_pass.SetRenderTarget(renderer.cameraColorTarget);
        renderer.EnqueuePass(m_pass);
    }
}
